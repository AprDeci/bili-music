import 'dart:math';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/data/import/favorites_import_repository.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_candidate.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_platform.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_result.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_status.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_track.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_matcher.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_state.dart';
import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_import_controller.g.dart';

@Riverpod(keepAlive: true)
class FavoritesImportController extends _$FavoritesImportController {
  late final FavoritesImportRepository _repository = FavoritesImportRepository(
    metingRepository: ref.read(metingRepositoryProvider),
    biliSearchRepository: BiliSearchRepository(
      ref.read(biliApiClientProvider),
      ref.read(biliClientProvider.notifier),
    ),
  );

  final FavoritesImportMatcher _matcher = const FavoritesImportMatcher();
  final AppLogger _logger = AppLogger('FavoritesImportController');
  final Random _random = Random();

  bool _cancelRequested = false;
  int _jobId = 0;

  @override
  FavoritesImportState build() {
    return FavoritesImportState.initial();
  }

  void updatePlaylistId(String value) {
    state = state.copyWith(
      request: state.request.copyWith(playlistId: value),
      clearErrorMessage: true,
    );
  }

  void updatePlatform(FavoritesImportPlatform platform) {
    state = state.copyWith(
      request: state.request.copyWith(platform: platform),
      clearErrorMessage: true,
    );
  }

  Future<void> startImport() async {
    if (state.isRunning || !state.request.isValid) {
      return;
    }

    final int jobId = ++_jobId;
    _cancelRequested = false;
    state = state.copyWith(
      status: FavoritesImportStatus.loadingPlaylist,
      totalCount: 0,
      processedCount: 0,
      matchedCount: 0,
      failedCount: 0,
      currentTrack: null,
      currentCandidate: null,
      results: const <FavoritesImportResult>[],
      errorMessage: null,
      startedAt: DateTime.now(),
      finishedAt: null,
    );

    try {
      final List<FavoritesImportTrack> tracks = await _repository
          .fetchPlaylistTracks(
            playlistId: state.request.playlistId,
            platform: state.request.platform,
          );
      if (_isStale(jobId)) {
        return;
      }

      state = state.copyWith(
        status: FavoritesImportStatus.running,
        totalCount: tracks.length,
      );

      // 循环匹配
      for (final FavoritesImportTrack track in tracks) {
        if (_shouldStop(jobId)) {
          break;
        }

        state = state.copyWith(
          currentTrack: track,
          clearCurrentCandidate: true,
          clearErrorMessage: true,
        );

        await Future.delayed(_jitterDelay());
        if (_shouldStop(jobId)) {
          break;
        }

        await _processTrack(track, jobId);
      }

      if (_isStale(jobId)) {
        return;
      }

      state = state.copyWith(
        status: _cancelRequested
            ? FavoritesImportStatus.canceled
            : FavoritesImportStatus.completed,
        currentTrack: null,
        clearCurrentCandidate: true,
        finishedAt: DateTime.now(),
      );
    } on Object catch (error) {
      if (_isStale(jobId)) {
        return;
      }
      _logger.e('导入歌单失败：$error');
      state = state.copyWith(
        status: FavoritesImportStatus.failed,
        errorMessage: error.toString(),
        currentTrack: null,
        clearCurrentCandidate: true,
        finishedAt: DateTime.now(),
      );
    }
  }

  Future<void> cancelImport() async {
    if (!state.isRunning) {
      return;
    }
    _cancelRequested = true;
    state = state.copyWith(status: FavoritesImportStatus.canceling);
  }

  void reset() {
    _cancelRequested = false;
    _jobId++;
    state = FavoritesImportState.initial().copyWith(request: state.request);
  }

  String buildManualSearchKeyword(FavoritesImportTrack track) {
    return _matcher.buildQuery(track);
  }

  Future<List<FavoritesImportCandidate>> searchManualCandidates({
    required FavoritesImportTrack track,
    required String keyword,
  }) async {
    final String query = keyword.trim().isEmpty
        ? _matcher.buildQuery(track)
        : keyword.trim();
    if (query.isEmpty) {
      return const <FavoritesImportCandidate>[];
    }

    final List<SearchResultItem> results = await _repository.searchVideos(
      query,
    );
    return results.map(_matcher.toCandidate).toList(growable: false);
  }

  void replaceResultCandidate({
    required FavoritesImportResult result,
    required FavoritesImportCandidate candidate,
  }) {
    _replaceResult(
      result,
      result.copyWith(
        status: FavoritesImportStatus.completed,
        candidate: candidate,
        clearMessage: true,
        finishedAt: DateTime.now(),
      ),
    );
  }

  void clearResultCandidate(FavoritesImportResult result) {
    _replaceResult(
      result,
      result.copyWith(
        status: FavoritesImportStatus.failed,
        clearCandidate: true,
        message: '已清空匹配。',
        finishedAt: DateTime.now(),
      ),
    );
  }

  // 匹配视频
  Future<void> _processTrack(FavoritesImportTrack track, int jobId) async {
    try {
      final String query = _matcher.buildQuery(track);
      final List<SearchResultItem> searchResults = query.isEmpty
          ? const <SearchResultItem>[]
          : await _repository.searchVideos(query);
      if (_isStale(jobId)) {
        return;
      }

      final FavoritesImportCandidate? candidate = _matcher.matchTrack(
        track: track,
        candidates: searchResults,
      );

      _appendResult(
        jobId: jobId,
        result: FavoritesImportResult(
          track: track,
          status: candidate == null
              ? FavoritesImportStatus.failed
              : FavoritesImportStatus.completed,
          candidate: candidate,
          message: candidate == null ? '未找到合适的 Bilibili 视频。' : null,
          finishedAt: DateTime.now(),
        ),
        currentCandidate: candidate,
      );
    } on Object catch (error) {
      if (_isStale(jobId)) {
        return;
      }
      _appendResult(
        jobId: jobId,
        result: FavoritesImportResult(
          track: track,
          status: FavoritesImportStatus.failed,
          message: error.toString(),
          finishedAt: DateTime.now(),
        ),
      );
    }
  }

  void _appendResult({
    required int jobId,
    required FavoritesImportResult result,
    FavoritesImportCandidate? currentCandidate,
  }) {
    if (_isStale(jobId)) {
      return;
    }

    final List<FavoritesImportResult> nextResults = <FavoritesImportResult>[
      ...state.results,
      result,
    ];
    state = state.copyWith(
      processedCount: state.processedCount + 1,
      matchedCount: state.matchedCount + (result.isMatched ? 1 : 0),
      failedCount: state.failedCount + (result.isMatched ? 0 : 1),
      currentCandidate: currentCandidate,
      results: nextResults,
    );
  }

  void _replaceResult(
    FavoritesImportResult oldResult,
    FavoritesImportResult newResult,
  ) {
    final int index = _findResultIndex(oldResult);
    if (index < 0) {
      return;
    }

    final List<FavoritesImportResult> nextResults = <FavoritesImportResult>[
      ...state.results,
    ];
    nextResults[index] = newResult;
    state = state.copyWith(
      results: nextResults,
      matchedCount: nextResults
          .where((FavoritesImportResult item) => item.isMatched)
          .length,
      failedCount: nextResults
          .where((FavoritesImportResult item) => !item.isMatched)
          .length,
    );
  }

  int _findResultIndex(FavoritesImportResult target) {
    final int identityIndex = state.results.indexWhere(
      (FavoritesImportResult item) => identical(item, target),
    );
    if (identityIndex >= 0) {
      return identityIndex;
    }

    return state.results.indexWhere((FavoritesImportResult item) {
      return item.finishedAt == target.finishedAt &&
          item.track.id == target.track.id &&
          item.track.title == target.track.title &&
          item.track.author == target.track.author;
    });
  }

  bool _shouldStop(int jobId) {
    return _cancelRequested || _isStale(jobId);
  }

  bool _isStale(int jobId) {
    return jobId != _jobId;
  }

  Duration _jitterDelay() {
    return Duration(milliseconds: 1200 + _random.nextInt(201) - 100);
  }
}
