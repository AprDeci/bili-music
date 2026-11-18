import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_cache_limit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_cache_provider.g.dart';

@Riverpod(keepAlive: true)
PlayerAudioCacheRepository playerAudioCacheRepository(Ref ref) {
  final AppSettingsStore store = ref.read(appSettingsStoreProvider);
  return PlayerAudioCacheRepository(
    AppAudioCacheManager.instance,
    readLimitBytes: () => ref.read(audioCacheLimitLogicProvider).bytes,
    readIndex: () async =>
        store.readString(HiveKeys.playerAudioCacheIndex, defaultValue: '[]'),
    writeIndex: (String value) =>
        store.writeString(HiveKeys.playerAudioCacheIndex, value),
  );
}

@Riverpod(keepAlive: true)
class AudioCacheLimitLogic extends _$AudioCacheLimitLogic {
  @override
  AudioCacheLimit build() => AudioCacheLimit.fromStorage(
    ref
        .read(appSettingsStoreProvider)
        .readString(
          HiveKeys.playerAudioCacheLimit,
          defaultValue: AudioCacheLimit.mb512.name,
        ),
  );

  Future<void> setLimit(AudioCacheLimit limit) async {
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.playerAudioCacheLimit, limit.name);
    state = limit;
    await ref.read(playerAudioCacheRepositoryProvider).trim();
  }
}
