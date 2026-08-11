import 'dart:io';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:bilimusic/feature/statistics/ui/song_statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Box<Map> box;

  setUpAll(() {
    Hive.init(Directory.systemTemp.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map>('song_statistics_page_test');
    await box.clear();
  });

  tearDown(() async {
    await box.close();
  });

  testWidgets('shows empty state when song has no playback record', (
    WidgetTester tester,
  ) async {
    final PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      title: '测试歌曲',
      author: '测试作者',
      coverUrl: '',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsTrackerProvider.overrideWithValue(
            StatisticsTracker(
              const Stream.empty(),
              StatisticsLocalRepository(box),
            ),
          ),
        ],
        child: MaterialApp(home: SongStatisticsPage(item: item)),
      ),
    );

    expect(find.text('测试歌曲'), findsOneWidget);
    expect(find.text('测试作者'), findsOneWidget);
    expect(find.text('还没有播放记录'), findsOneWidget);
    expect(find.text('播放这首歌后，统计数据会显示在这里。'), findsOneWidget);
  });
}
