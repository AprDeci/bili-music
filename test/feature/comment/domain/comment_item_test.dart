import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('withLike 幂等且点赞数不会被减成负数', () {
    final CommentItem item = _comment(likeCount: 3, action: 0);

    final CommentItem liked = item.withLike(true);
    expect(liked.isLiked, isTrue);
    expect(liked.likeCount, 4);
    expect(item.likeCount, 3);
    expect(liked.withLike(true), same(liked));

    final CommentItem unliked = liked.withLike(false);
    expect(unliked.isLiked, isFalse);
    expect(unliked.likeCount, 3);

    expect(_comment(likeCount: 0, action: 0).withLike(false).likeCount, 0);
    expect(_comment(likeCount: 0, action: 1).withLike(false).likeCount, 0);
  });
}

CommentItem _comment({required int likeCount, required int action}) {
  return CommentItem(
    rpid: 1,
    oid: 2,
    type: 1,
    root: 0,
    parent: 0,
    replyCount: 0,
    likeCount: likeCount,
    action: action,
    publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
    message: 'hi',
    memberName: 'tester',
    memberAvatarUrl: '',
  );
}
