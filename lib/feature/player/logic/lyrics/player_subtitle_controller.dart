import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/bili_subtitle_repository.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_subtitle_controller.g.dart';

@riverpod
BiliSubtitleRepository biliSubtitleRepository(Ref ref) =>
    BiliSubtitleRepository(ref.read(biliClientProvider.notifier));

@Riverpod(keepAlive: true)
class PlayerSubtitleController extends _$PlayerSubtitleController {
  int _discoveryGeneration = 0;
  int _selectionGeneration = 0;
  final Map<String, List<BiliSubtitleLine>> _lineCache = {};
  final Map<String, int> _offsets = {};

  @override
  PlayerSubtitleState build() {
    ref.watch(
      playerControllerProvider.select(
        (value) => (value.currentItem?.stableId, value.currentItem?.kind),
      ),
    );
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? account = item != null && (item.cid ?? 0) > 0
        ? ref.watch(
            biliSessionControllerProvider.select(
              (value) => value?.isLoggedIn == true ? value?.dedeUserId : null,
            ),
          )
        : null;
    final int generation = ++_discoveryGeneration;
    ++_selectionGeneration;
    _lineCache.clear();
    _offsets.clear();
    final bool canDiscover =
        item != null && (item.cid ?? 0) > 0 && account != null;
    if (canDiscover) {
      unawaited(Future<void>.microtask(() => _discover(item, generation)));
    }
    return PlayerSubtitleState(
      stableId: item?.stableId,
      isDiscovering: canDiscover,
    );
  }

  bool _isCurrent(int generation, String stableId) {
    if (!ref.mounted) return false;
    final PlayerSubtitleState current = state;
    return generation == _discoveryGeneration && current.stableId == stableId;
  }

  Future<void> _discover(PlayableItem item, int generation) async {
    if (!_isCurrent(generation, item.stableId)) return;
    final int selection = _selectionGeneration;
    try {
      final List<BiliSubtitleTrack> tracks = await ref
          .read(biliSubtitleRepositoryProvider)
          .fetchTracks(item);
      if (!_isCurrent(generation, item.stableId)) return;
      state = state.copyWith(tracks: tracks, isDiscovering: false);
      if (item.isSpoken &&
          tracks.isNotEmpty &&
          selection == _selectionGeneration) {
        final BiliSubtitleTrack track =
            tracks.where((value) => !value.isTranslated).firstOrNull ??
            tracks.first;
        await selectTrack(track.id);
      }
    } on Object {
      if (!_isCurrent(generation, item.stableId)) return;
      state = state.copyWith(isDiscovering: false, errorMessage: '字幕列表获取失败');
    }
  }

  void useMeting() {
    ++_selectionGeneration;
    state = state.copyWith(
      selectedTrackId: null,
      pendingTrackId: null,
      lines: const [],
      offsetMs: 0,
      errorMessage: null,
    );
  }

  Future<bool> selectTrack(String trackId) async {
    final BiliSubtitleTrack? track = state.tracks
        .where((value) => value.id == trackId)
        .firstOrNull;
    final String? stableId = state.stableId;
    if (track == null || stableId == null) return false;
    final int discovery = _discoveryGeneration;
    final int selection = ++_selectionGeneration;
    state = state.copyWith(pendingTrackId: trackId, errorMessage: null);
    try {
      final List<BiliSubtitleLine> lines =
          _lineCache[trackId] ??
          await _fetchLines(track, discovery, stableId, selection);
      if (!_isCurrent(discovery, stableId) ||
          selection != _selectionGeneration) {
        return false;
      }
      if (lines.isEmpty) throw const BiliSubtitleException('字幕内容为空');
      _lineCache[trackId] = lines;
      state = state.copyWith(
        selectedTrackId: trackId,
        pendingTrackId: null,
        lines: lines,
        offsetMs: _offsets[trackId] ?? 0,
        errorMessage: null,
      );
      return true;
    } on Object {
      if (!_isCurrent(discovery, stableId) ||
          selection != _selectionGeneration) {
        return false;
      }
      state = state.copyWith(pendingTrackId: null, errorMessage: '字幕加载失败，请重试');
      return false;
    }
  }

  Future<List<BiliSubtitleLine>> _fetchLines(
    BiliSubtitleTrack track,
    int discovery,
    String stableId,
    int selection,
  ) async {
    final BiliSubtitleRepository repository = ref.read(
      biliSubtitleRepositoryProvider,
    );
    try {
      return await repository.fetchLines(track);
    } on DioException catch (error) {
      if (error.response?.statusCode != 403 ||
          !_isCurrent(discovery, stableId) ||
          selection != _selectionGeneration) {
        rethrow;
      }
      final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
      if (item?.stableId != stableId) rethrow;
      final List<BiliSubtitleTrack> tracks = await repository.fetchTracks(
        item!,
      );
      if (!_isCurrent(discovery, stableId) ||
          selection != _selectionGeneration) {
        rethrow;
      }
      final BiliSubtitleTrack? refreshed = tracks
          .where((value) => value.id == track.id)
          .firstOrNull;
      if (refreshed == null) rethrow;
      state = state.copyWith(tracks: tracks);
      return repository.fetchLines(refreshed);
    }
  }

  void adjustOffset(int deltaMs) {
    final String? id = state.selectedTrackId;
    if (id == null) return;
    final int offset = state.offsetMs + deltaMs;
    _offsets[id] = offset;
    state = state.copyWith(offsetMs: offset);
  }
}
