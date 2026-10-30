import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Video title',
  author: 'Video UP',
  coverUrl: '',
);
final Metadata _metadata = Metadata(
  stableId: _item.stableId,
  title: 'Song title',
  artist: 'Song artist',
);

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;
  late ProviderContainer container;

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
      playerControllerProvider.overrideWith(_FakePlayerController.new),
      metadataControllerProvider.overrideWith(_FakeMetadataController.new),
    ],
  );

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'player-display-test-',
    );
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>(HiveBoxNames.prefs);
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    await Hive.openLazyBox<Metadata>(metadataCacheBoxName);
    container = createContainer();
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test(
    'defaults to metadata without writing the existing cover preference',
    () {
      expect(container.read(playerDisplaySettingsLogicProvider), isTrue);
      expect(prefsBox.get(HiveKeys.playerUseMetadataCover), isNull);
      expect(container.read(playerDisplayProvider).title, _metadata.title);
      expect(container.read(playerDisplaySourceLogicProvider), isNull);
    },
  );

  test(
    'reads the old cover key and persists source preference across containers',
    () async {
      await prefsBox.put(HiveKeys.playerUseMetadataCover, 'false');
      expect(container.read(playerDisplaySettingsLogicProvider), isFalse);
      expect(container.read(playerDisplayProvider).title, _item.title);

      await container
          .read(playerDisplaySettingsLogicProvider.notifier)
          .setPreferMetadata(true);
      expect(container.read(playerDisplaySettingsLogicProvider), isTrue);
      expect(prefsBox.get(HiveKeys.playerUseMetadataCover), 'true');
      expect(container.read(playerDisplayProvider).title, _metadata.title);

      container.dispose();
      container = createContainer();
      expect(container.read(playerDisplaySettingsLogicProvider), isTrue);
      expect(container.read(playerDisplayProvider).title, _metadata.title);
    },
  );

  test(
    'default changes apply until an override and track changes reset it',
    () async {
      container.listen(playerDisplayProvider, (_, _) {}, fireImmediately: true);
      container.listen(
        playerDisplaySettingsLogicProvider,
        (_, _) {},
        fireImmediately: true,
      );
      final PlayerDisplaySettingsLogic settings = container.read(
        playerDisplaySettingsLogicProvider.notifier,
      );
      final PlayerDisplaySourceLogic source = container.read(
        playerDisplaySourceLogicProvider.notifier,
      );
      final _FakePlayerController player =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;

      await settings.setPreferMetadata(false);
      await container.pump();
      expect(
        container.read(playerDisplayProvider).source,
        PlayerDisplaySource.bilibili,
      );
      expect(container.read(playerDisplaySourceLogicProvider), isNull);
      source.toggle();
      await container.pump();
      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.metadata,
      );
      expect(container.read(playerDisplayProvider).title, _metadata.title);

      await settings.setPreferMetadata(true);
      await settings.setPreferMetadata(false);
      await container.pump();
      expect(container.read(playerDisplayProvider).title, _metadata.title);
      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.metadata,
      );

      player.show(_item.copyWith(title: 'Updated video title'));
      await container.pump();
      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.metadata,
      );

      for (final PlayableItem next in <PlayableItem>[
        _item.copyWith(bvid: 'BV2xx411c7mD'),
        _item.copyWith(bvid: 'BV2xx411c7mD', cid: 123, page: 2),
      ]) {
        player.show(next);
        await container.pump();
        expect(container.read(playerDisplaySourceLogicProvider), isNull);
        expect(
          container.read(playerDisplayProvider).source,
          PlayerDisplaySource.bilibili,
        );
        expect(container.read(playerDisplayProvider).title, next.title);
        source.toggle();
        await container.pump();
        expect(
          container.read(playerDisplaySourceLogicProvider),
          PlayerDisplaySource.metadata,
        );
      }

      player.show(null);
      await container.pump();
      expect(container.read(playerDisplaySourceLogicProvider), isNull);
      expect(container.read(playerDisplayProvider).stableId, isNull);
    },
  );

  test(
    'queue preview uses current display and cached metadata without playing',
    () async {
      final PlayableItem next = _item.copyWith(bvid: 'next');
      await container
          .read(metadataCacheRepositoryProvider)
          .putCachedMetadata(
            item: next,
            metadata: Metadata(
              stableId: next.stableId,
              title: 'Cached song',
              artist: 'Cached artist',
              albumArtUrl: 'https://example.com/album.jpg',
            ),
          );
      final PlayerDisplayInfo current = await container.read(
        playerQueueDisplayProvider(_item).future,
      );
      expect(current.title, 'Song title');
      final PlayerDisplayInfo preview = await container.read(
        playerQueueDisplayProvider(next).future,
      );
      expect(preview.title, 'Cached song');
      expect(preview.artist, 'Cached artist');
      expect(preview.coverUrl, 'https://example.com/album.jpg');
      expect(container.read(playerControllerProvider).currentItem, _item);
      final PlayableItem uncached = _item.copyWith(bvid: 'uncached');
      expect(
        (await container.read(
          playerQueueDisplayProvider(uncached).future,
        )).title,
        uncached.title,
      );
    },
  );

  test(
    'queue preview respects the saved Bilibili display preference',
    () async {
      await prefsBox.put(HiveKeys.playerUseMetadataCover, 'false');
      final PlayableItem next = _item.copyWith(bvid: 'next');
      await container
          .read(metadataCacheRepositoryProvider)
          .putCachedMetadata(
            item: next,
            metadata: Metadata(stableId: next.stableId, title: 'Cached song'),
          );
      final PlayerDisplayInfo preview = await container.read(
        playerQueueDisplayProvider(next).future,
      );
      expect(preview.title, next.title);
      expect(preview.source, PlayerDisplaySource.bilibili);
    },
  );

  test('spoken current and same-id queue preview bypass music cache', () async {
    container.listen(playerDisplayProvider, (_, _) {}, fireImmediately: true);
    final player =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    final spoken = _item.copyWith(kind: CollectionKind.spoken);
    final spokenPreview = await container.read(
      playerQueueDisplayProvider(spoken).future,
    );
    expect(spokenPreview.title, _item.title);
    expect(spokenPreview.source, PlayerDisplaySource.bilibili);
    expect(spokenPreview.canToggleSource, isFalse);
    player.show(spoken);
    await container.pump();
    expect(container.read(playerDisplayProvider).title, _item.title);
    expect(
      container.read(playerDisplayProvider).source,
      PlayerDisplaySource.bilibili,
    );
    container.read(playerDisplaySourceLogicProvider.notifier).toggle();
    expect(container.read(playerDisplaySourceLogicProvider), isNull);
    final next = spoken.copyWith(bvid: 'next-spoken');
    await container
        .read(metadataCacheRepositoryProvider)
        .putCachedMetadata(
          item: next,
          metadata: Metadata(
            stableId: next.stableId,
            title: 'Wrong cached music',
          ),
        );
    final preview = await container.read(
      playerQueueDisplayProvider(next).future,
    );
    expect(preview.title, next.title);
    expect(preview.source, PlayerDisplaySource.bilibili);
    expect(preview.canToggleSource, isFalse);
  });

  test('ignores metadata whose envelope belongs to another track', () async {
    container.listen(playerDisplayProvider, (_, _) {}, fireImmediately: true);
    final _FakeMetadataController metadata =
        container.read(metadataControllerProvider.notifier)
            as _FakeMetadataController;
    metadata.show(
      MetadataState(
        stableId: 'another-track',
        metadata: _metadata,
        hasSearched: true,
      ),
    );
    await container.pump();
    expect(container.read(playerDisplayProvider).title, _item.title);
    expect(container.read(playerDisplayProvider).canToggleSource, isFalse);
  });
}

class _FakePlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState(currentItem: _item);

  void show(PlayableItem? item) => state = state.copyWith(currentItem: item);
}

class _FakeMetadataController extends MetadataController {
  @override
  MetadataState build() => MetadataState(
    stableId: _item.stableId,
    metadata: _metadata,
    hasSearched: true,
  );

  void show(MetadataState value) => state = value;
}
