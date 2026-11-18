import 'dart:async';
import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_cache_limit.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_cache_provider.dart';
import 'package:bilimusic/feature/setting/ui/cache_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<String> prefs;
  const MethodChannel pathProvider = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'cache-settings-page-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (_) async => directory.path);
    Hive.init(directory.path);
    prefs = await Hive.openBox<String>(HiveBoxNames.prefs);
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    await Hive.openLazyBox<Metadata>(metadataCacheBoxName);
    await Hive.openBox<String>(chapterCacheBoxName);
    await CacheUtil.getTotalCacheSizeBytes();
  });

  tearDownAll(() async {
    await AppImageCacheManager.instance.dispose();
    await AppAudioCacheManager.instance.dispose();
    await AppLyricsCacheManager.instance.dispose();
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
    await directory.delete(recursive: true);
  });

  testWidgets(
    'quota options persist, block repeat changes and recover from failure',
    (WidgetTester tester) async {
      final _ControlledSettingsStore store = _ControlledSettingsStore(prefs);
      final _RecordingCache repository = _RecordingCache();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appSettingsStoreProvider.overrideWithValue(store),
          playerAudioCacheRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: FlutterSmartDialog.init(),
            home: const CacheSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder dropdownFinder = find.byType(
        DropdownButton<AudioCacheLimit>,
      );
      DropdownButton<AudioCacheLimit> dropdown() =>
          tester.widget<DropdownButton<AudioCacheLimit>>(dropdownFinder);
      expect(find.text('缓存存储上限'), findsOneWidget);
      expect(find.textContaining('仅限制自动缓存'), findsNothing);
      final Finder dividerFinder = find.byType(Divider).first;
      expect(
        tester.getTopLeft(dividerFinder).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(dropdownFinder).dy),
      );
      expect(
        tester.getBottomLeft(dividerFinder).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.text('缓存已清理')).dy),
      );
      expect(dropdown().value, AudioCacheLimit.mb512);
      expect(
        dropdown().items!.map(
          (DropdownMenuItem<AudioCacheLimit> item) => item.value,
        ),
        AudioCacheLimit.values,
      );
      expect(
        dropdown().items!.map(
          (DropdownMenuItem<AudioCacheLimit> item) => (item.child as Text).data,
        ),
        AudioCacheLimit.values.map((AudioCacheLimit limit) => limit.label),
      );

      store.pendingWrite = Completer<void>();
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('256 MB').last);
      await tester.pumpAndSettle();
      expect(dropdown().onChanged, isNull);
      expect(dropdown().value, AudioCacheLimit.mb512);
      expect(store.writeCalls, 1);
      await tester.tap(dropdownFinder);
      await tester.pump();
      expect(store.writeCalls, 1);

      store.pendingWrite!.completeError(StateError('Preferences write failed'));
      await tester.pumpAndSettle();
      expect(dropdown().onChanged, isNotNull);
      expect(dropdown().value, AudioCacheLimit.mb512);
      expect(store.values[HiveKeys.playerAudioCacheLimit], isNull);
      expect(find.text('音频自动缓存额度更新失败，请重试'), findsOneWidget);
      expect(repository.trimCalls, 0);
      expect(repository.clearCalls, 0);

      store.pendingWrite = null;
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('关闭').last);
      await tester.pumpAndSettle();
      expect(dropdown().value, AudioCacheLimit.disabled);
      expect(
        store.values[HiveKeys.playerAudioCacheLimit],
        AudioCacheLimit.disabled.name,
      );
      expect(find.textContaining('仅限制自动缓存'), findsNothing);
      expect(find.textContaining('关闭后仍可读取旧缓存'), findsNothing);
      expect(store.writeCalls, 2);
      expect(repository.trimCalls, 1);
      expect(repository.clearCalls, 0);

      final Future<void> dismissing = SmartDialog.dismiss(
        status: SmartStatus.toast,
      );
      await tester.pumpAndSettle();
      await dismissing;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

class _ControlledSettingsStore extends AppSettingsStore {
  _ControlledSettingsStore(super.prefsBox);

  Completer<void>? pendingWrite;
  int writeCalls = 0;
  final Map<String, String> values = <String, String>{};

  @override
  String readString(String key, {required String defaultValue}) =>
      values[key] ?? defaultValue;

  @override
  Future<void> writeString(String key, String value) async {
    writeCalls++;
    await pendingWrite?.future;
    values[key] = value;
  }
}

class _RecordingCache implements PlayerAudioCacheRepository {
  int trimCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> trim() async {
    trimCalls++;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
