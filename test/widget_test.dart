import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('player page shows swipe indicator and meta page', (
    WidgetTester tester,
  ) async {
    const PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1xx411c7mD',
      title: '测试播放内容',
      author: '测试UP主',
      coverUrl: '',
      durationText: '03:21',
      playCountText: '12.3万',
      danmakuCountText: '456',
      likeCountText: '8,888',
      coinCountText: '666',
      favoriteCountText: '1.2万',
      shareCountText: '234',
      replyCountText: '321',
      publishTimeText: '2026-03-27',
      description: '这是一段测试简介。',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PlayerPage(initialItem: item)),
      ),
    );
    await tester.pump();

    expect(find.text('测试播放内容'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('音频信息'), findsOneWidget);
    expect(find.text('播放'), findsOneWidget);
  });
}
