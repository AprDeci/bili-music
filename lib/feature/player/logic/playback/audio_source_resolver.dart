import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

class AudioResolutionRequest {
  const AudioResolutionRequest({
    required this.item,
    required this.qualityPreference,
    this.preferredQualityId,
    this.allowQualityFallback = false,
  });

  final PlayableItem item;
  final PlayerAudioQualityPreference qualityPreference;
  final int? preferredQualityId;
  final bool allowQualityFallback;

  AudioResolutionRequest withQualityFallback() {
    return AudioResolutionRequest(
      item: item,
      qualityPreference: qualityPreference,
      preferredQualityId: preferredQualityId,
      allowQualityFallback: true,
    );
  }

  String get cacheKey => audioSourceCacheKey(
    item,
    preference: qualityPreference,
    preferredQualityId: preferredQualityId,
  );
}

String audioSourceCacheKey(
  PlayableItem item, {
  required PlayerAudioQualityPreference preference,
  int? preferredQualityId,
}) {
  final String overrideKey = preferredQualityId?.toString() ?? 'default';
  final String partKey = item.cid == null || item.cid! <= 0
      ? ':page:${item.page ?? 1}'
      : '';
  return '${item.stableId}$partKey:${preference.storageValue}:$overrideKey:${item.kind.name}:${item.collectionId ?? ''}';
}

abstract interface class AudioSourceResolver {
  String get id;

  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request);
}

class AudioSourceChain implements AudioSourceResolver {
  AudioSourceChain(List<AudioSourceResolver> sources)
    : sources = List<AudioSourceResolver>.unmodifiable(sources);

  final List<AudioSourceResolver> sources;

  @override
  String get id =>
      'chain(${sources.map((AudioSourceResolver source) => source.id).join('>')})';

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) async {
    for (final AudioSourceResolver source in sources) {
      final ResolvedQueueEntry? entry = await source.resolve(request);
      if (entry != null) {
        return entry;
      }
    }
    return null;
  }
}

class CachedAudioSourceResolver implements AudioSourceResolver {
  const CachedAudioSourceResolver(this._cacheRepository);

  final PlayerAudioCacheRepository _cacheRepository;

  @override
  String get id => 'cached-audio';

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) async {
    final CachedAudio? diskCache = await _cacheRepository.lookupCachedAudio(
      item: request.item,
      preference: request.qualityPreference,
      preferredQualityId: request.preferredQualityId,
      allowQualityFallback: request.allowQualityFallback,
    );
    if (diskCache == null) {
      return null;
    }
    final AudioCacheMetadata metadata = diskCache.metadata;
    return ResolvedQueueEntry(
      item: request.item.copyWith(
        cid: metadata.cid,
        page: metadata.page ?? request.item.page,
        pageTitle: (request.item.pageTitle?.trim().isNotEmpty ?? false)
            ? request.item.pageTitle
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
}

class MemoryAudioSourceResolver implements AudioSourceResolver {
  final Map<String, ResolvedQueueEntry> _entries =
      <String, ResolvedQueueEntry>{};

  @override
  String get id => 'memory';

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) async {
    return _entries[request.cacheKey];
  }

  void store(AudioResolutionRequest request, ResolvedQueueEntry entry) {
    _entries[request.cacheKey] = entry;
    _entries[audioSourceCacheKey(
          entry.item,
          preference: request.qualityPreference,
          preferredQualityId: request.preferredQualityId,
        )] =
        entry;
  }

  void remove(String cacheKey) {
    _entries.remove(cacheKey);
  }

  void removeForItem(PlayableItem item) {
    final String prefix = '${item.stableId}:';
    _entries.removeWhere(
      (String key, ResolvedQueueEntry _) => key.startsWith(prefix),
    );
  }

  void clear() {
    _entries.clear();
  }

  int get length => _entries.length;
}

class BiliDashAudioSourceResolver implements AudioSourceResolver {
  const BiliDashAudioSourceResolver({
    required this._repository,
    required this._audioCacheRepository,
    required this._readSession,
  });

  final BiliPlayerRepository _repository;
  final PlayerAudioCacheRepository _audioCacheRepository;
  final BiliSession? Function() _readSession;

  @override
  String get id => 'bili-dash';

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) async {
    final PlayerLoadResult loadResult = await _repository.resolveAudioStream(
      request.item,
      session: _readSession(),
      qualityPreference: request.qualityPreference,
      preferredQualityId: request.preferredQualityId,
    );
    return ResolvedQueueEntry(
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
