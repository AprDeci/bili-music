import 'dart:async';

import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_controller.g.dart';

@riverpod
MusicChartRepository musicChartRepository(Ref ref) {
  return MusicChartRepository();
}

@Riverpod(keepAlive: true)
class MusicChartController extends _$MusicChartController {
  int _requestId = 0;

  @override
  MusicChartState build() {
    unawaited(Future<void>.microtask(_load));
    return const MusicChartState(isLoading: true);
  }

  Future<void> refresh() => _load();

  Future<void> selectPlatform(MusicChartPlatform platform) async {
    if (state.platform == platform) {
      return;
    }
    state = state.copyWith(
      platform: platform,
      tracks: const <MusicChartTrack>[],
      isLoading: true,
      errorMessage: null,
    );
    await _load();
  }

  Future<void> _load() async {
    final int requestId = ++_requestId;
    final MusicChartPlatform platform = state.platform;
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final List<MusicChartTrack> tracks = await ref
          .read(musicChartRepositoryProvider)
          .fetchTracks(platform);
      if (!ref.mounted ||
          requestId != _requestId ||
          state.platform != platform) {
        return;
      }
      state = state.copyWith(
        tracks: tracks,
        isLoading: false,
        errorMessage: null,
      );
    } on Object catch (error) {
      if (!ref.mounted ||
          requestId != _requestId ||
          state.platform != platform) {
        return;
      }
      state = state.copyWith(
        tracks: const <MusicChartTrack>[],
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
