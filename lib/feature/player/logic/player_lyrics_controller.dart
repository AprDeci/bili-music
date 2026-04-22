import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/logic/meting_logic.dart';
import 'package:bilimusic/feature/player/data/player_lyrics_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_cache_entry.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyrics_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerLyricsController extends _$PlayerLyricsController {
  final AppLogger _logger = AppLogger('PlayerLyricsController');

  int _generation = 0;

  @override
  PlayerLyricsState build() {
    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      if (previous?.currentItem?.stableId == next.currentItem?.stableId) {
        return;
      }
      unawaited(_loadCurrentItemLyrics());
    }, fireImmediately: true);

    return const PlayerLyricsState();
  }

  Future<void> retryCurrent() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    if (item == null) {
      state = const PlayerLyricsState();
      return;
    }

    await _loadForItem(item, ignoreCache: true);
  }

  Future<void> adjustOffset(int deltaMs) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (stableId == null || state.stableId != stableId) {
      return;
    }

    final PlayerLyricsState nextState = state.copyWith(
      lyricOffsetMs: state.lyricOffsetMs + deltaMs,
    );
    state = nextState;
    await _saveCacheIfEligible(item: item!, nextState: nextState);
  }

  Future<void> resetOffset() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (stableId == null || state.stableId != stableId) {
      return;
    }

    final PlayerLyricsState nextState = state.copyWith(lyricOffsetMs: 0);
    state = nextState;
    await _saveCacheIfEligible(item: item!, nextState: nextState);
  }

  Future<void> searchManual(String keyword) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (item == null || stableId == null || state.stableId != stableId) {
      return;
    }

    final String trimmedKeyword = keyword.trim();
    final PlayerLyricsState searchingState = state.copyWith(
      searchKeyword: trimmedKeyword,
      manualSearchError: null,
      isSearching: true,
    );
    state = searchingState;

    try {
      final MetingLogic metingLogic = ref.read(metingLogicProvider);
      final MetingSearchResponse response = await metingLogic.search(
        keyword: trimmedKeyword,
        server: metingLogic.resolveServer(trimmedKeyword),
      );
      if (state.stableId != stableId) {
        return;
      }
      final PlayerLyricsState nextState = state.copyWith(
        searchKeyword: response.keyword,
        searchResults: response.results,
        manualSearchError: null,
        isSearching: false,
      );
      state = nextState;
    } on MetingException catch (error) {
      if (state.stableId != stableId) {
        return;
      }
      final PlayerLyricsState nextState = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: error.message,
        isSearching: false,
      );
      state = nextState;
    } on Object catch (error) {
      if (state.stableId != stableId) {
        return;
      }
      _logger.e('manual lyrics search failed', error);
      final PlayerLyricsState nextState = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: '搜索失败：$error',
        isSearching: false,
      );
      state = nextState;
    }
  }

  Future<void> applyManualResult(MetingSearchItem item) async {
    final PlayableItem? currentItem = ref
        .read(playerControllerProvider)
        .currentItem;
    final String? stableId = currentItem?.stableId;
    if (currentItem == null || stableId == null || state.stableId != stableId) {
      return;
    }

    final PlayerLyricsState applyingState = state.copyWith(
      manualSearchError: null,
      isSearching: true,
    );
    state = applyingState;

    try {
      final String rawLyrics = await ref
          .read(metingLogicProvider)
          .fetchLyrics(item);
      if (state.stableId != stableId) {
        return;
      }
      final PlayerLyricsState nextState = state.copyWith(
        rawLyrics: _normalizeLyrics(rawLyrics),
        errorMessage: null,
        manualSearchError: null,
        isSearching: false,
        hasSearched: true,
      );
      state = nextState;
      await _saveCacheIfEligible(item: currentItem, nextState: nextState);
    } on MetingException catch (error) {
      if (state.stableId != stableId) {
        return;
      }
      final PlayerLyricsState nextState = state.copyWith(
        manualSearchError: error.message,
        isSearching: false,
      );
      state = nextState;
    } on Object catch (error) {
      if (state.stableId != stableId) {
        return;
      }
      _logger.e('apply manual lyrics result failed', error);
      final PlayerLyricsState nextState = state.copyWith(
        manualSearchError: '歌词加载失败：$error',
        isSearching: false,
      );
      state = nextState;
    }
  }

  Future<void> _loadCurrentItemLyrics() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _loadForItem(item);
  }

  Future<void> _loadForItem(
    PlayableItem? item, {
    bool ignoreCache = false,
  }) async {
    final int requestGeneration = ++_generation;
    if (item == null) {
      state = const PlayerLyricsState();
      return;
    }

    final String stableId = item.stableId;
    state = PlayerLyricsState(stableId: stableId, isLoading: true);

    if (!ignoreCache) {
      final PlayerLyricsCacheEntry? cached = await ref
          .read(playerLyricsCacheRepositoryProvider)
          .getCachedEntry(item: item);
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }
      if (cached != null) {
        state = PlayerLyricsState(
          stableId: stableId,
          rawLyrics: _normalizeLyrics(cached.rawLyrics),
          lyricOffsetMs: cached.lyricOffsetMs,
          hasSearched: true,
        );
        return;
      }
    }

    try {
      final lookupResult = await _findLyricsForItem(item);
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }

      final String? normalizedLyrics = _normalizeLyrics(lookupResult.rawLyrics);
      final PlayerLyricsState nextState = PlayerLyricsState(
        stableId: stableId,
        rawLyrics: normalizedLyrics,
        searchKeyword: lookupResult.searchKeyword,
        searchResults: lookupResult.searchResults,
        hasSearched: true,
      );
      state = nextState;
      await _saveCacheIfEligible(item: item, nextState: nextState);
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }
      state = PlayerLyricsState(
        stableId: stableId,
        errorMessage: error.message,
        searchKeyword: _defaultSearchKeyword(item),
        hasSearched: true,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }
      _logger.e('load lyrics failed', error);
      state = PlayerLyricsState(
        stableId: stableId,
        errorMessage: '歌词查询失败：$error',
        searchKeyword: _defaultSearchKeyword(item),
        hasSearched: true,
      );
    }
  }

  Future<
    ({
      String? rawLyrics,
      String? searchKeyword,
      List<MetingSearchItem> searchResults,
    })
  >
  _findLyricsForItem(PlayableItem item) async {
    String? fallbackKeyword;
    final MetingLogic metingLogic = ref.read(metingLogicProvider);
    for (final String title in item.lyricSearchTitles) {
      final String keyword = metingLogic.extractSearchKeyword(title).trim();
      if (fallbackKeyword == null && keyword.isNotEmpty) {
        fallbackKeyword = keyword;
      }
      final MetingSearchResponse response = await metingLogic.search(
        keyword: keyword,
        server: metingLogic.resolveServer(title),
      );
      for (final MetingSearchItem result in response.results) {
        final String? normalizedLyrics = _normalizeLyrics(
          await metingLogic.fetchLyrics(result),
        );
        if (normalizedLyrics != null) {
          return (
            rawLyrics: normalizedLyrics,
            searchKeyword: keyword.isNotEmpty ? keyword : fallbackKeyword,
            searchResults: response.results,
          );
        }
      }
    }

    return (
      rawLyrics: null,
      searchKeyword: fallbackKeyword,
      searchResults: const <MetingSearchItem>[],
    );
  }

  bool _isActiveRequest(int requestGeneration, String stableId) {
    return requestGeneration == _generation && state.stableId == stableId;
  }

  String? _normalizeLyrics(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _defaultSearchKeyword(PlayableItem item) {
    for (final String title in item.lyricSearchTitles) {
      final String keyword = title.trim();
      if (keyword.isNotEmpty) {
        return keyword;
      }
    }
    return null;
  }

  Future<void> _saveCacheIfEligible({
    required PlayableItem item,
    required PlayerLyricsState nextState,
  }) async {
    if (!_shouldCacheLyrics(item)) {
      return;
    }

    await ref
        .read(playerLyricsCacheRepositoryProvider)
        .saveEntry(
          PlayerLyricsCacheEntry(
            stableId: item.stableId,
            rawLyrics: _normalizeLyrics(nextState.rawLyrics),
            lyricOffsetMs: nextState.lyricOffsetMs,
            updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  bool _shouldCacheLyrics(PlayableItem item) {
    return ref
        .read(favoritesControllerProvider)
        .collectionsForItem(item)
        .isNotEmpty;
  }
}
