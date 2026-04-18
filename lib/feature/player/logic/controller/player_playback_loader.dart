import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';

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
    required String? queueSourceLabel,
    required Duration initialPosition,
    required void Function(PlayerStatusHint hint) onStatusHint,
  }) async {
    final MediaItem mediaItem = buildPlayerMediaItem(
      entry.item,
      audioStream: entry.audioStream,
      queueSourceLabel: queueSourceLabel,
      duration: entry.audioStream.duration,
    );
    onStatusHint(PlayerStatusHint.connectingStream);
    final Duration? effectiveInitialPosition = initialPosition > Duration.zero
        ? initialPosition
        : null;
    final File? cachedFile = await _audioCacheRepository.getCachedFile(
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
          tag: mediaItem,
          initialPosition: effectiveInitialPosition,
        );
      } on Object catch (error) {
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
      }
    }

    _logEvent(
      'loadQueueIndex:remote-source',
      details: <String, Object?>{'stableId': entry.item.stableId},
    );
    return _audioEngine.setRemoteSource(
      uri: Uri.parse(entry.audioStream.streamUrl),
      headers: entry.audioStream.headers.isEmpty
          ? null
          : entry.audioStream.headers,
      tag: mediaItem,
      initialPosition: effectiveInitialPosition,
    );
  }

  Future<void> cacheEntryInBackground(ResolvedQueueEntry entry) async {
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
  });

  final PlayableItem item;
  final List<PlayableItem> availableParts;
  final AudioStreamInfo audioStream;
}
