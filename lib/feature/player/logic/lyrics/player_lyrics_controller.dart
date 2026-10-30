import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/logic/meting_logic.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
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
      if (previous?.currentItem?.stableId == next.currentItem?.stableId &&
          previous?.currentItem?.kind == next.currentItem?.kind &&
          previous?.currentItem?.collectionId ==
              next.currentItem?.collectionId) {
        return;
      }
      unawaited(_loadCurrentItemLyrics());
    });
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    if (item != null && !item.isSpoken) {
      final int generation = _generation;
      unawaited(
        Future<void>.microtask(() async {
          if (ref.mounted && generation == _generation) {
            await _loadCurrentItemLyrics();
          }
        }),
      );
    }
    return PlayerLyricsState(
      stableId: item?.stableId,
      isLoading: item != null && !item.isSpoken,
    );
  }

  Future<void> retryCurrent() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _loadForItem(item, ignoreCache: true);
  }

  Future<void> adjustOffset(int deltaMs) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }

    final PlayerLyricsState nextState = state.copyWith(
      lyricOffsetMs: state.lyricOffsetMs + deltaMs,
    );
    state = nextState;
    await _saveCacheIfEligible(item: item, nextState: nextState);
  }

  Future<void> resetOffset() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }

    final PlayerLyricsState nextState = state.copyWith(lyricOffsetMs: 0);
    state = nextState;
    await _saveCacheIfEligible(item: item, nextState: nextState);
  }

  Future<void> searchManual(String keyword, {MetingServer? server}) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }

    final int requestGeneration = _generation;
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
        server:
            server ??
            ref
                .read(metingSourcePreferenceLogicProvider)
                .resolve(trimmedKeyword),
      );
      if (!_isActiveRequest(requestGeneration, item)) {
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
      if (!_isActiveRequest(requestGeneration, item)) {
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
      if (!_isActiveRequest(requestGeneration, item)) {
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
    if (currentItem == null ||
        currentItem.isSpoken ||
        state.stableId != stableId) {
      return;
    }

    final int requestGeneration = ++_generation;
    final PlayerLyricsState applyingState = state.copyWith(
      manualSearchError: null,
      isSearching: true,
      isLoading: false,
    );
    state = applyingState;

    try {
      final String? rawLyrics =
          (await ref.read(metingLogicProvider).fetchLyrics(item))
              .preferredMainLyric;
      if (!_isActiveRequest(requestGeneration, currentItem)) {
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
      if (!_isActiveRequest(requestGeneration, currentItem)) {
        return;
      }
      final PlayerLyricsState nextState = state.copyWith(
        manualSearchError: error.message,
        isSearching: false,
      );
      state = nextState;
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, currentItem)) {
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
    if (item == null || item.isSpoken) {
      state = PlayerLyricsState(stableId: item?.stableId);
      return;
    }

    final String stableId = item.stableId;
    state = PlayerLyricsState(stableId: stableId, isLoading: true);

    if (!ignoreCache) {
      final PlayerLyricsCacheEntry? cached = await ref
          .read(playerLyricsCacheRepositoryProvider)
          .getCachedEntry(item: item);
      if (!_isActiveRequest(requestGeneration, item)) {
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
      final lookupResult = await _findLyricsForItem(item, requestGeneration);
      if (!_isActiveRequest(requestGeneration, item)) {
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
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      state = PlayerLyricsState(
        stableId: stableId,
        errorMessage: error.message,
        searchKeyword: _defaultSearchKeyword(item),
        hasSearched: true,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, item)) {
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
  _findLyricsForItem(PlayableItem item, int requestGeneration) async {
    void checkActive() {
      if (!_isActiveRequest(requestGeneration, item)) {
        throw StateError('Lyrics lookup is no longer active');
      }
    }

    checkActive();
    String? fallbackKeyword;
    final MetingLogic metingLogic = ref.read(metingLogicProvider);
    final MetingServer server = ref
        .read(metingSourcePreferenceLogicProvider)
        .resolve(item.lyricSearchTitles.join(' '));
    for (final String title in item.lyricSearchTitles) {
      final String keyword = (await metingLogic.resolveSearchKeyword(
        title,
      )).trim();
      checkActive();
      if (fallbackKeyword == null && keyword.isNotEmpty) {
        fallbackKeyword = keyword;
      }
      final MetingSearchResponse response = await metingLogic.search(
        keyword: keyword,
        server: server,
      );
      checkActive();
      for (final MetingSearchItem result in response.results) {
        checkActive();
        final String? normalizedLyrics = _normalizeLyrics(
          (await metingLogic.fetchLyrics(result)).preferredMainLyric,
        );
        checkActive();
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

  bool _isActiveRequest(int requestGeneration, PlayableItem item) {
    if (!ref.mounted || requestGeneration != _generation) {
      return false;
    }
    final PlayableItem? currentItem = ref
        .read(playerControllerProvider)
        .currentItem;
    return currentItem != null &&
        !currentItem.isSpoken &&
        currentItem.stableId == item.stableId &&
        currentItem.kind == item.kind &&
        currentItem.collectionId == item.collectionId &&
        state.stableId == item.stableId;
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
          item: item,
          entry: PlayerLyricsCacheEntry(
            stableId: item.stableId,
            rawLyrics: _normalizeLyrics(nextState.rawLyrics),
            lyricOffsetMs: nextState.lyricOffsetMs,
            updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  bool _shouldCacheLyrics(PlayableItem item) {
    if (item.isSpoken) {
      return false;
    }
    return ref
        .read(favoritesControllerProvider)
        .collectionsForItem(item)
        .isNotEmpty;
  }
}
