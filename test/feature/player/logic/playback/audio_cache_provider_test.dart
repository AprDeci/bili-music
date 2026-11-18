import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_cache_limit.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_cache_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<String> prefs;
  late _RecordingAudioCacheRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'audio_cache_provider_test_',
    );
    Hive.init(directory.path);
    prefs = await Hive.openBox<String>(HiveBoxNames.prefs);
    repository = _RecordingAudioCacheRepository();
  });

  tearDown(() async {
    await Hive.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  ProviderContainer createContainer({AppSettingsStore? store}) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appSettingsStoreProvider.overrideWithValue(
          store ?? AppSettingsStore(prefs),
        ),
        playerAudioCacheRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to 512 MB without writing preferences or trimming', () {
    final ProviderContainer container = createContainer();

    expect(container.read(audioCacheLimitLogicProvider), AudioCacheLimit.mb512);
    expect(prefs.get(HiveKeys.playerAudioCacheLimit), isNull);
    expect(repository.trimCalls, 0);
    expect(repository.clearCalls, 0);
  });

  test('unknown stored limit falls back to 512 MB', () async {
    await prefs.put(HiveKeys.playerAudioCacheLimit, 'future-limit');
    final ProviderContainer container = createContainer();

    expect(container.read(audioCacheLimitLogicProvider), AudioCacheLimit.mb512);
    expect(prefs.get(HiveKeys.playerAudioCacheLimit), 'future-limit');
    expect(repository.trimCalls, 0);
  });

  for (final AudioCacheLimit limit in AudioCacheLimit.values) {
    test('persists and restores ${limit.name}', () async {
      final ProviderContainer container = createContainer();

      await container
          .read(audioCacheLimitLogicProvider.notifier)
          .setLimit(limit);

      expect(container.read(audioCacheLimitLogicProvider), limit);
      expect(prefs.get(HiveKeys.playerAudioCacheLimit), limit.name);
      expect(repository.trimCalls, 1);
      expect(repository.clearCalls, 0);
      container.dispose();

      final ProviderContainer restored = createContainer();
      expect(restored.read(audioCacheLimitLogicProvider), limit);
      expect(repository.trimCalls, 1);
    });
  }

  test('disabling requests trim without clearing existing cache', () async {
    final ProviderContainer container = createContainer();

    await container
        .read(audioCacheLimitLogicProvider.notifier)
        .setLimit(AudioCacheLimit.disabled);

    expect(
      container.read(audioCacheLimitLogicProvider),
      AudioCacheLimit.disabled,
    );
    expect(repository.trimCalls, 1);
    expect(repository.clearCalls, 0);
    expect(repository.cachedKeys, <String>['existing-audio']);
  });

  test('failed save preserves state and cache without trimming', () async {
    await prefs.put(HiveKeys.playerAudioCacheLimit, AudioCacheLimit.gb1.name);
    final ProviderContainer container = createContainer(
      store: _FailingSettingsStore(prefs),
    );
    expect(container.read(audioCacheLimitLogicProvider), AudioCacheLimit.gb1);

    await expectLater(
      container
          .read(audioCacheLimitLogicProvider.notifier)
          .setLimit(AudioCacheLimit.disabled),
      throwsStateError,
    );

    expect(container.read(audioCacheLimitLogicProvider), AudioCacheLimit.gb1);
    expect(prefs.get(HiveKeys.playerAudioCacheLimit), AudioCacheLimit.gb1.name);
    expect(repository.trimCalls, 0);
    expect(repository.clearCalls, 0);
    expect(repository.cachedKeys, <String>['existing-audio']);
  });

  test('enum storage values round trip with correct quotas and labels', () {
    const Map<AudioCacheLimit, int> bytes = <AudioCacheLimit, int>{
      AudioCacheLimit.disabled: 0,
      AudioCacheLimit.mb256: 256 * 1024 * 1024,
      AudioCacheLimit.mb512: 512 * 1024 * 1024,
      AudioCacheLimit.gb1: 1024 * 1024 * 1024,
      AudioCacheLimit.gb2: 2 * 1024 * 1024 * 1024,
    };
    const Map<AudioCacheLimit, String> labels = <AudioCacheLimit, String>{
      AudioCacheLimit.disabled: '关闭',
      AudioCacheLimit.mb256: '256 MB',
      AudioCacheLimit.mb512: '512 MB',
      AudioCacheLimit.gb1: '1 GB',
      AudioCacheLimit.gb2: '2 GB',
    };

    expect(AudioCacheLimit.values, bytes.keys.toList());
    for (final AudioCacheLimit limit in AudioCacheLimit.values) {
      expect(AudioCacheLimit.fromStorage(limit.name), limit);
      expect(limit.bytes, bytes[limit]);
      expect(limit.label, labels[limit]);
    }
    expect(AudioCacheLimit.fromStorage(''), AudioCacheLimit.mb512);
    expect(AudioCacheLimit.fromStorage('unknown'), AudioCacheLimit.mb512);
  });
}

class _RecordingAudioCacheRepository implements PlayerAudioCacheRepository {
  int trimCalls = 0;
  int clearCalls = 0;
  final List<String> cachedKeys = <String>['existing-audio'];

  @override
  Future<void> trim() async {
    trimCalls++;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    cachedKeys.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingSettingsStore extends AppSettingsStore {
  const _FailingSettingsStore(super.prefsBox);

  @override
  Future<void> writeString(String key, String value) async {
    throw StateError('Preferences write failed');
  }
}
