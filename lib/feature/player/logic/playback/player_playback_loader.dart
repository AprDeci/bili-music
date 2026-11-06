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
import 'package:bilimusic/feature/player/logic/playback/audio_source_resolver.dart';
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
    this.downloadedSource,
    List<AudioSourceResolver> extraSources = const <AudioSourceResolver>[],
  }) : _resolveAllParts = resolveAllParts ?? _repository.resolveAllParts,
       _isOffline = isOffline ?? NetUtil.isOffline,
       _extraSources = List<AudioSourceResolver>.unmodifiable(extraSources);

  final BiliPlayerRepository _repository;
  final PlayerAudioCacheRepository _audioCacheRepository;
  final PlayerAudioEngine _audioEngine;
  final BiliSession? Function() _readSession;
  final PlayerAudioQualityPreference Function() _readQualityPreference;
  final PlayerControllerLogger _logEvent;
  final Future<List<PlayableItem>> Function(PlayableItem item) _resolveAllParts;
  final Future<bool> Function() _isOffline;
  final AudioSourceResolver? downloadedSource;
  final List<AudioSourceResolver> _extraSources;

  late final CachedAudioSourceResolver _cachedSource =
      CachedAudioSourceResolver(_audioCacheRepository);
  late final MemoryAudioSourceResolver _memorySource =
      MemoryAudioSourceResolver();
  late final BiliDashAudioSourceResolver _dashSource =
      BiliDashAudioSourceResolver(
        repository: _repository,
        audioCacheRepository: _audioCacheRepository,
        readSession: _readSession,
      );
  late final AudioSourceChain _onlineSourceChain = AudioSourceChain(
    <AudioSourceResolver>[..._extraSources, _dashSource],
  );

  void removeResolvedEntryCachesForItem(PlayableItem item) {
    _memorySource.removeForItem(item);
  }

  void clearResolvedEntryCache({
    required PlayableItem item,
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
  }) {
    _memorySource.remove(
      resolvedEntryCacheKey(
        item,
        preference: preference,
        preferredQualityId: preferredQualityId,
      ),
    );
  }

  String resolvedEntryCacheKey(
    PlayableItem item, {
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
  }) {
    return audioSourceCacheKey(
      item,
      preference: preference,
      preferredQualityId: preferredQualityId,
    );
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
    if (!item.hasIdentity) {
      throw const BiliPlayerException('当前搜索结果缺少可播放的视频标识。');
    }
    final AudioResolutionRequest request = AudioResolutionRequest(
      item: item,
      qualityPreference: _readQualityPreference(),
      preferredQualityId: preferredQualityId,
    );

    final ResolvedQueueEntry? downloaded = await downloadedSource?.resolve(
      request,
    );
    if (downloaded != null) {
      return downloaded;
    }

    final ResolvedQueueEntry? diskCache = await _cachedSource.resolve(request);
    if (diskCache != null) {
      return diskCache;
    }

    if (await _isOffline()) {
      return await downloadedSource?.resolve(request.withQualityFallback()) ??
          await _cachedSource.resolve(request.withQualityFallback()) ??
          (throw const BiliPlayerException('设备处于离线状态，且没有可用的音频缓存。'));
    }

    final ResolvedQueueEntry? cached = await _memorySource.resolve(request);
    if (cached != null) {
      return cached;
    }

    try {
      final ResolvedQueueEntry? resolved = await _onlineSourceChain.resolve(
        request,
      );
      if (resolved != null) {
        _memorySource.store(request, resolved);
        return resolved;
      }
      throw const BiliPlayerException('未能解析出可播放的音频源。');
    } on Object catch (error, stackTrace) {
      if (_isRetryableNetworkError(error)) {
        final ResolvedQueueEntry? fallback =
            await downloadedSource?.resolve(request.withQualityFallback()) ??
            await _cachedSource.resolve(request.withQualityFallback());
        if (fallback != null) {
          return fallback;
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  bool _isRetryableNetworkError(Object error) {
    return error is SocketException ||
        error is TimeoutException ||
        (error is DioException &&
            error.type != DioExceptionType.badResponse &&
            error.type != DioExceptionType.cancel);
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
    bool Function()? isCurrent,
  }) async {
    if (!(isCurrent?.call() ?? true)) return null;
    final Duration? effectiveInitialPosition =
        isCurrent == null && initialPosition > Duration.zero
        ? initialPosition
        : null;
    File? cachedFile = entry.cachedFile;
    cachedFile ??= await _audioCacheRepository.getCachedFile(
      item: entry.item,
      audioStream: entry.audioStream,
    );
    if (!(isCurrent?.call() ?? true)) return null;

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
        if (!(isCurrent?.call() ?? true)) return null;
        final Duration? duration = await _audioEngine.setFileSource(
          filePath: cachedFile.path,
          initialPosition: effectiveInitialPosition,
        );
        return await _seekInitialPosition(duration, initialPosition, isCurrent);
      } on Object catch (error, stackTrace) {
        if (!(isCurrent?.call() ?? true)) return null;
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
        if (!(isCurrent?.call() ?? true)) return null;
        if (entry.audioStream.streamUrl.isEmpty) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
    }

    if (!(isCurrent?.call() ?? true)) return null;
    onStatusHint(PlayerStatusHint.connectingStream);
    _logEvent(
      'loadQueueIndex:remote-source',
      details: <String, Object?>{'stableId': entry.item.stableId},
    );
    if (!(isCurrent?.call() ?? true)) return null;
    final Duration? duration = await _audioEngine.setRemoteSource(
      uri: Uri.parse(entry.audioStream.streamUrl),
      headers: entry.audioStream.headers.isEmpty
          ? null
          : entry.audioStream.headers,
      initialPosition: effectiveInitialPosition,
    );
    if (!(isCurrent?.call() ?? true)) return null;
    unawaited(_cacheEntry(entry));
    return _seekInitialPosition(duration, initialPosition, isCurrent);
  }

  Future<Duration?> _seekInitialPosition(
    Duration? duration,
    Duration position,
    bool Function()? isCurrent,
  ) async {
    if (!(isCurrent?.call() ?? true)) return null;
    if (isCurrent == null || position <= Duration.zero) return duration;
    if (duration == null || duration <= Duration.zero) {
      duration = await _audioEngine.durationStream
          .firstWhere(
            (Duration? value) => value != null && value > Duration.zero,
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
    }
    if (!isCurrent()) return null;
    await _audioEngine.seek(position);
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
