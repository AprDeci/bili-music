import 'dart:async';
import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';

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
  });

  final BiliPlayerRepository _repository;
  final PlayerAudioCacheRepository _audioCacheRepository;
  final PlayerAudioEngine _audioEngine;
  final BiliSession? Function() _readSession;
  final PlayerAudioQualityPreference Function() _readQualityPreference;
  final PlayerControllerLogger _logEvent;

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
    return '${item.stableId}:${preference.storageValue}:$overrideKey';
  }

  Future<ResolvedQueueEntry> resolveQueueEntry(
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
    final ResolvedQueueEntry? cached = _resolvedEntries[cacheKey];
    if (cached != null) {
      return cached;
    }

    if (!item.hasIdentity) {
      throw const BiliPlayerException('当前搜索结果缺少可播放的视频标识。');
    }

    final CachedAudio? diskCache = await _audioCacheRepository
        .lookupCachedAudio(
          item: item,
          preference: qualityPreference,
          preferredQualityId: preferredQualityId,
        );
    if (diskCache != null) {
      final AudioCacheMetadata metadata = diskCache.metadata;
      final AudioStreamInfo audioStream = AudioStreamInfo(
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
      );
      final ResolvedQueueEntry entry = ResolvedQueueEntry(
        item: item,
        availableParts: const <PlayableItem>[],
        audioStream: audioStream,
        cachedFile: diskCache.file,
      );
      _resolvedEntries[cacheKey] = entry;
      return entry;
    }

    final PlayerLoadResult loadResult = await _repository.resolveAudioStream(
      item,
      session: _readSession(),
      qualityPreference: qualityPreference,
      preferredQualityId: preferredQualityId,
    );
    final ResolvedQueueEntry entry = ResolvedQueueEntry(
      item: loadResult.item,
      availableParts: List<PlayableItem>.unmodifiable(
        loadResult.availableParts,
      ),
      audioStream: loadResult.audioStream,
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
