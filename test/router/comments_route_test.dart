import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CommentTarget extraTarget = CommentTarget(
    oid: 99,
    type: 1,
    aid: 99,
    title: '来自 extra',
  );

  test('extra 存在时优先使用 extra', () {
    final CommentTarget? target = commentTargetFromRoute(
      extra: extraTarget,
      queryParameters: <String, String>{'aid': '1'},
    );

    expect(target, same(extraTarget));
  });

  test('aid 查询参数可构造评论目标', () {
    final CommentTarget? target = commentTargetFromRoute(
      extra: null,
      queryParameters: <String, String>{
        'aid': '42',
        'title': '深链标题',
        'cover': 'https://i0.hdslb.com/cover.jpg',
      },
    );

    expect(target, isNotNull);
    expect(target!.oid, 42);
    expect(target.type, 1);
    expect(target.aid, 42);
    expect(target.title, '深链标题');
    expect(target.coverUrl, 'https://i0.hdslb.com/cover.jpg');
  });

  test('仅 bvid 时也能构造评论目标', () {
    final CommentTarget? target = commentTargetFromRoute(
      extra: null,
      queryParameters: <String, String>{'bvid': 'BV1xx411c7mD', 'type': '1'},
    );

    expect(target, isNotNull);
    expect(target!.bvid, 'BV1xx411c7mD');
    expect(target.aid, isNull);
  });

  test('oid 与 type 参数生效', () {
    final CommentTarget? target = commentTargetFromRoute(
      extra: null,
      queryParameters: <String, String>{'oid': '123', 'type': '12'},
    );

    expect(target, isNotNull);
    expect(target!.oid, 123);
    expect(target.type, 12);
    expect(target.aid, 123);
  });

  test('缺少有效目标参数时返回 null', () {
    expect(
      commentTargetFromRoute(
        extra: null,
        queryParameters: const <String, String>{},
      ),
      isNull,
    );
    expect(
      commentTargetFromRoute(
        extra: 'not-a-target',
        queryParameters: const <String, String>{'title': '没有 aid/bvid'},
      ),
      isNull,
    );
  });
}
