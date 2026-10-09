import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/ui/components/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('点击卡片触发回复，点点赞只触发点赞', (WidgetTester tester) async {
    int cardTaps = 0;
    int likeTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommentCard(
            item: _comment(),
            onTap: () => cardTaps++,
            onToggleLike: () => likeTaps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('回复 0'));
    await tester.pumpAndSettle();
    expect(cardTaps, 1);

    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined));
    await tester.pumpAndSettle();
    expect(likeTaps, 1);
    expect(cardTaps, 1);
  });

  testWidgets('没有回调时卡片不响应点击', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CommentCard(item: _comment())),
      ),
    );

    await tester.tap(find.text('回复 0'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

CommentItem _comment() {
  return CommentItem(
    rpid: 1,
    oid: 2,
    type: 1,
    root: 0,
    parent: 0,
    replyCount: 0,
    likeCount: 3,
    action: 0,
    publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
    message: '你好',
    memberName: 'tester',
    memberAvatarUrl: '',
  );
}
