import 'dart:async';
import 'dart:io';

import 'package:bilimusic/common/util/net_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:dio/dio.dart';

typedef PlayerControllerLogger =
    void Function(String event, {Map<String, Object?>? details});

class PlayerPlaybackLoader {
  PlayerPlaybackLoader({
    required this._repository,
    required this._audioCacheRepository,
    required this._audioEngine,
    required this._readSession,
    required this._readQualityPreference,
    required this._logEvent,
    Future<List<PlayableItem>> Function(PlayableItem item)? resolveAllParts,
    Future<bool> Function()? isOffline,
  }) : _resolveAllParts = resolveAllParts ?? _repository.resolveAllParts,
       _isOffline = isOffline ?? NetUtil.isOffline;

  final BiliPlayerRepository _repository;
  final PlayerAudioCacheRepository _audioCacheRepository;
  final PlayerAudioEngine _audioEngine;
  final BiliSession? Function() _readSession;
  final PlayerAudioQualityPreference Function() _readQualityPreference;
  final PlayerControllerLogger _logEvent;
  final Future<List<PlayableItem>> Function(PlayableItem item) _resolveAllParts;
  final Future<bool> Function() _isOffline;

  final Map<String, ResolvedQueueEntry> _resolvedEntries =
      <String, ResolvedQueueEntry>{};

  void removeResolvedEntryCachesForItem(PlayableItem item) {
    final String prefix = '${item.stableId}:';
    _resolvedEntries.removeWhere(
      (String key, ResolvedQueueEntry _) => key.startsWith(prefix),
    );
  }

  void clearResolvedEntryCache({
    required PlayableItem item,
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
  }) {
    final String cacheKey = resolvedEntryCacheKey(
      item,
      preference: preference,
      preferredQualityId: preferredQualityId,
    );
    _resolvedEntries.remove(cacheKey);
  }

  String resolvedEntryCacheKey(
    PlayableItem item, {
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
  }) {
    final String overrideKey = preferredQualityId?.toString() ?? 'default';
    final String partKey = item.cid == null || item.cid! <= 0
        ? ':page:${item.page ?? 1}'
        : '';
    return '${item.stableId}$partKey:${preference.storageValue}:$overrideKey';
  }

  Future<ResolvedQueueEntry> resolveQueueEntry(
    PlayableItem item, {
    int? preferredQualityId,
  }) => _resolveQueueEntry(
    item,
    preferredQualityId: preferredQualityId,
  ).timeout(const Duration(seconds: 5));

  Future<ResolvedQueueEntry> _resolveQueueEntry(
    PlayableItem item, {
    int? preferredQualityId,
  }) async {
    final PlayerAudioQualityPreference qualityPreference =
        _readQualityPreference();
    final String cacheKey = resolvedEntryCacheKey(
      item,
      preference: qualityPreference,
      preferredQualityId: preferredQualityId,
    );
    if (!item.hasIdentity) {
      throw const BiliPlayerException('当前搜索结果缺少可播放的视频标识。');
    }

    final ResolvedQueueEntry? diskCache = await _resolveCachedEntry(
      item,
      preference: qualityPreference,
      preferredQualityId: preferredQualityId,
    );
    if (diskCache != null) {
      return diskCache;
    }

    if (await _isOffline()) {
      return await _resolveCachedEntry(
            item,
            preference: qualityPreference,
            preferredQualityId: preferredQualityId,
            allowQualityFallback: true,
          ) ??
          (throw const BiliPlayerException('设备处于离线状态，且没有可用的音频缓存。'));
    }

    final ResolvedQueueEntry? cached = _resolvedEntries[cacheKey];
    if (cached != null) {
      return cached;
    }

    late final PlayerLoadResult loadResult;
    try {
      loadResult = await _repository.resolveAudioStream(
        item,
        session: _readSession(),
        qualityPreference: qualityPreference,
        preferredQualityId: preferredQualityId,
      );
    } on Object catch (error, stackTrace) {
      if (error is SocketException ||
          error is TimeoutException ||
          (error is DioException &&
              error.type != DioExceptionType.badResponse &&
              error.type != DioExceptionType.cancel)) {
        final ResolvedQueueEntry? fallback = await _resolveCachedEntry(
          item,
          preference: qualityPreference,
          preferredQualityId: preferredQualityId,
          allowQualityFallback: true,
        );
        if (fallback != null) {
          return fallback;
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    final ResolvedQueueEntry entry = ResolvedQueueEntry(
      item: loadResult.item,
      availableParts: List<PlayableItem>.unmodifiable(
        loadResult.availableParts,
      ),
      audioStream: loadResult.audioStream,
      cachedFile: await _audioCacheRepository.getCachedFile(
        item: loadResult.item,
        audioStream: loadResult.audioStream,
      ),
    );
    _resolvedEntries[cacheKey] = entry;
    _resolvedEntries[resolvedEntryCacheKey(
          loadResult.item,
          preference: qualityPreference,
          preferredQualityId: preferredQualityId,
        )] =
        entry;
    return entry;
  }

  Future<ResolvedQueueEntry?> _resolveCachedEntry(
    PlayableItem item, {
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
    bool allowQualityFallback = false,
  }) async {
    final CachedAudio? diskCache = await _audioCacheRepository
        .lookupCachedAudio(
          item: item,
          preference: preference,
          preferredQualityId: preferredQualityId,
          allowQualityFallback: allowQualityFallback,
        );
    if (diskCache == null) {
      return null;
    }
    final AudioCacheMetadata metadata = diskCache.metadata;
    return ResolvedQueueEntry(
      item: item.copyWith(
        cid: metadata.cid,
        page: metadata.page ?? item.page,
        pageTitle: (item.pageTitle?.trim().isNotEmpty ?? false)
            ? item.pageTitle
            : metadata.pageTitle,
      ),
      availableParts: const <PlayableItem>[],
      audioStream: AudioStreamInfo(
        streamUrl: '',
        backupUrls: const <String>[],
        headers: const <String, String>{},
        cid: metadata.cid,
        duration: metadata.durationMs == null
            ? null
            : Duration(milliseconds: metadata.durationMs!),
        bandwidth: metadata.bandwidth,
        availableQualities: <AudioQualityOption>[
          AudioQualityOption(
            qualityId: metadata.qualityId,
            bandwidth: metadata.bandwidth,
            label: metadata.qualityLabel ?? '本地缓存',
            isSelected: true,
          ),
        ],
        pageTitle: metadata.pageTitle,
        qualityId: metadata.qualityId,
        qualityLabel: metadata.qualityLabel,
      ),
      cachedFile: diskCache.file,
    );
  }

  Future<ResolvedQueueEntry?> resolveCachedEntryParts(
    ResolvedQueueEntry entry,
  ) async {
    try {
      if (entry.availableParts.isNotEmpty || await _isOffline()) {
        return null;
      }
      final List<PlayableItem> parts = await _resolveAllParts(entry.item);
      final int cid = entry.item.cid ?? entry.audioStream.cid;
      final PlayableItem? item = parts
          .where((PlayableItem part) => part.cid == cid)
          .firstOrNull;
      if (item == null) {
        _logEvent(
          'cache-parts:current-part-not-found',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'cid': cid,
          },
        );
        return null;
      }
      AudioStreamInfo audioStream = entry.audioStream;
      try {
        final PlayerLoadResult result = await _repository.resolveAudioStream(
          item,
          session: _readSession(),
          qualityPreference: _readQualityPreference(),
          preferredQualityId: audioStream.qualityId,
        );
        final List<AudioQualityOption> qualities = <AudioQualityOption>[
          AudioQualityOption(
            qualityId: audioStream.qualityId,
            bandwidth: audioStream.bandwidth,
            label: audioStream.qualityLabel ?? '本地缓存',
            isSelected: true,
          ),
          for (final AudioQualityOption option
              in result.audioStream.availableQualities)
            if (option.qualityId != audioStream.qualityId)
              option.copyWith(isSelected: false),
        ];
        audioStream = AudioStreamInfo(
          streamUrl: audioStream.streamUrl,
          backupUrls: audioStream.backupUrls,
          headers: audioStream.headers,
          cid: audioStream.cid,
          duration: audioStream.duration,
          bandwidth: audioStream.bandwidth,
          availableQualities: qualities,
          pageTitle: audioStream.pageTitle,
          qualityId: audioStream.qualityId,
          qualityLabel: audioStream.qualityLabel,
        );
      } on Object catch (error) {
        _logEvent(
          'cache-qualities:failed',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'error': error,
          },
        );
      }
      return ResolvedQueueEntry(
        item: item,
        availableParts: List<PlayableItem>.unmodifiable(parts),
        audioStream: audioStream,
        cachedFile: entry.cachedFile,
      );
    } on Object catch (error) {
      _logEvent(
        'cache-parts:failed',
        details: <String, Object?>{
          'stableId': entry.item.stableId,
          'error': error,
        },
      );
      return null;
    }
  }

  Future<Duration?> setSourceForEntry({
    required ResolvedQueueEntry entry,
    required Duration initialPosition,
    required void Function(PlayerStatusHint hint) onStatusHint,
  }) async {
    final Duration? effectiveInitialPosition = initialPosition > Duration.zero
        ? initialPosition
        : null;
    File? cachedFile = entry.cachedFile;
    cachedFile ??= await _audioCacheRepository.getCachedFile(
      item: entry.item,
      audioStream: entry.audioStream,
    );

    if (cachedFile != null) {
      try {
        onStatusHint(PlayerStatusHint.loadingCache);
        _logEvent(
          'loadQueueIndex:cache-hit',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'path': cachedFile.path,
          },
        );
        return await _audioEngine.setFileSource(
          filePath: cachedFile.path,
          initialPosition: effectiveInitialPosition,
        );
      } on Object catch (error, stackTrace) {
        _logEvent(
          'loadQueueIndex:cache-fallback',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'error': error,
          },
        );
        await _audioCacheRepository.removeCachedFile(
          item: entry.item,
          audioStream: entry.audioStream,
        );
        if (entry.audioStream.streamUrl.isEmpty) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
    }

    onStatusHint(PlayerStatusHint.connectingStream);
    _logEvent(
      'loadQueueIndex:remote-source',
      details: <String, Object?>{'stableId': entry.item.stableId},
    );
    final Duration? duration = await _audioEngine.setRemoteSource(
      uri: Uri.parse(entry.audioStream.streamUrl),
      headers: entry.audioStream.headers.isEmpty
          ? null
          : entry.audioStream.headers,
      initialPosition: effectiveInitialPosition,
    );
    unawaited(_cacheEntry(entry));
    return duration;
  }

  Future<void> _cacheEntry(ResolvedQueueEntry entry) async {
    try {
      await _audioCacheRepository.cacheAudio(
        item: entry.item,
        audioStream: entry.audioStream,
      );
      _logEvent(
        'audio-cache:completed',
        details: <String, Object?>{'stableId': entry.item.stableId},
      );
    } on Object catch (error) {
      _logEvent(
        'audio-cache:failed',
        details: <String, Object?>{
          'stableId': entry.item.stableId,
          'error': error,
        },
      );
    }
  }

  List<PlayableItem> replaceQueueEntry({
    required List<PlayableItem> queue,
    required int index,
    required PlayableItem item,
  }) {
    if (index < 0 || index >= queue.length) {
      return queue;
    }

    final List<PlayableItem> nextQueue = List<PlayableItem>.of(queue);
    nextQueue[index] = item;
    return List<PlayableItem>.unmodifiable(nextQueue);
  }
}

class ResolvedQueueEntry {
  const ResolvedQueueEntry({
    required this.item,
    required this.availableParts,
    required this.audioStream,
    this.cachedFile,
  });

  final PlayableItem item;
  final List<PlayableItem> availableParts;
  final AudioStreamInfo audioStream;
  final File? cachedFile;
}
