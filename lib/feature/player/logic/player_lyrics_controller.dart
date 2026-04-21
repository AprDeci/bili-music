import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/logic/meting_logic.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyrics_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerLyricsController extends _$PlayerLyricsController {
  final AppLogger _logger = AppLogger('PlayerLyricsController');
  final Map<String, PlayerLyricsState> _cache = <String, PlayerLyricsState>{};

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

    _cache.remove(item.stableId);
    await _loadForItem(item);
  }

  Future<void> _loadCurrentItemLyrics() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _loadForItem(item);
  }

  Future<void> _loadForItem(PlayableItem? item) async {
    final int requestGeneration = ++_generation;
    if (item == null) {
      state = const PlayerLyricsState();
      return;
    }

    final String stableId = item.stableId;
    final PlayerLyricsState? cached = _cache[stableId];
    if (cached != null) {
      state = cached;
      return;
    }

    state = PlayerLyricsState(stableId: stableId, isLoading: true);

    try {
      final String? rawLyrics = await _findLyricsForItem(item);
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }

      final String? normalizedLyrics = _normalizeLyrics(rawLyrics);
      final PlayerLyricsState nextState = PlayerLyricsState(
        stableId: stableId,
        rawLyrics: normalizedLyrics,
        hasSearched: true,
      );
      _cache[stableId] = nextState;
      state = nextState;
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, stableId)) {
        return;
      }
      state = PlayerLyricsState(
        stableId: stableId,
        errorMessage: error.message,
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
        hasSearched: true,
      );
    }
  }

  Future<String?> _findLyricsForItem(PlayableItem item) async {
    for (final String title in item.lyricSearchTitles) {
      final String? rawLyrics = await ref
          .read(metingLogicProvider)
          .findLyrics(title: title);
      final String? normalizedLyrics = _normalizeLyrics(rawLyrics);
      if (normalizedLyrics != null) {
        return normalizedLyrics;
      }
    }

    return null;
  }

  bool _isActiveRequest(int requestGeneration, String stableId) {
    return requestGeneration == _generation && state.stableId == stableId;
  }

  String? _normalizeLyrics(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
