import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_blacklist_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'player_blacklist_controller_test_',
    );
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>(HiveBoxNames.prefs);
  });

  tearDown(() async {
    await prefsBox.close();
    await Hive.deleteBoxFromDisk(HiveBoxNames.prefs);
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('adds item, persists JSON, and filters blocked entries', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      playerBlacklistControllerProvider.notifier,
    );
    final PlayableItem blocked = _item(cid: 111, page: 1);
    final PlayableItem allowed = _item(cid: 222, page: 2);

    expect(container.read(playerBlacklistControllerProvider), isEmpty);

    final bool added = await controller.addItem(blocked);

    expect(added, isTrue);
    expect(controller.containsItem(blocked), isTrue);
    expect(controller.containsItem(allowed), isFalse);
    expect(
      controller.filterAllowedItems(<PlayableItem>[blocked, allowed]),
      <PlayableItem>[allowed],
    );

    final Object? raw = jsonDecode(
      prefsBox.get(HiveKeys.playerBlacklistEntries)!,
    );
    expect(raw, isA<List<dynamic>>());
    expect(
      (raw as List<dynamic>).single,
      containsPair('stableId', blocked.stableId),
    );
  });

  test('keeps one entry for duplicate item and supports removal', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      playerBlacklistControllerProvider.notifier,
    );
    final PlayableItem item = _item(cid: 111, page: 1);

    expect(await controller.addItem(item), isTrue);
    expect(await controller.addItem(item.copyWith(pageTitle: '新版标题')), isFalse);
    expect(container.read(playerBlacklistControllerProvider), hasLength(1));

    await controller.removeByStableId(item.stableId);

    expect(container.read(playerBlacklistControllerProvider), isEmpty);
    expect(controller.containsItem(item), isFalse);
  });

  test('returns empty list for malformed persisted JSON', () async {
    await prefsBox.put(HiveKeys.playerBlacklistEntries, '{bad json');

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(playerBlacklistControllerProvider), isEmpty);
  });
}

PlayableItem _item({required int cid, required int page}) {
  return PlayableItem(
    aid: 100,
    bvid: 'BV100',
    title: '测试投稿',
    author: 'tester',
    coverUrl: 'https://example.com/cover.jpg',
    cid: cid,
    page: page,
    pageTitle: '分段 $page',
  );
}
