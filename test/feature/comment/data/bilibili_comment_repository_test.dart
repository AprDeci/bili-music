import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final CommentTarget target = CommentTarget.video(aid: 100);

  test('likeComment 以表单提交 csrf 与 action', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 0,
      'message': '0',
    });
    final BiliCommentRepository repository = BiliCommentRepository(client);

    await repository.likeComment(target, rpid: 9, liked: true);

    expect(client.path, '/x/v2/reply/action');
    expect(client.contentType, Headers.formUrlEncodedContentType);
    expect(client.data, <String, dynamic>{
      'type': 1,
      'oid': 100,
      'rpid': 9,
      'action': 1,
      'csrf': 'csrf',
    });
  });

  test('likeComment 把服务端错误码翻译成可读提示', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 12002,
      'message': '评论区已关闭',
    });
    final BiliCommentRepository repository = BiliCommentRepository(client);

    await expectLater(
      repository.likeComment(target, rpid: 9, liked: false),
      throwsA(
        isA<BiliCommentException>().having(
          (BiliCommentException e) => e.message,
          'message',
          '评论区已关闭',
        ),
      ),
    );
  });

  test('addComment 裁剪正文并解析服务端回传的评论', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 0,
      'data': <String, dynamic>{
        'rpid': 55,
        'need_captcha': false,
        'reply': <String, dynamic>{
          'rpid': 55,
          'oid': 100,
          'type': 1,
          'root': 0,
          'parent': 0,
          'count': 0,
          'like': 7,
          'action': 1,
          'ctime': 1700000000,
          'member': <String, dynamic>{'uname': '测试用户', 'avatar': ''},
          'content': <String, dynamic>{'message': '你好'},
        },
      },
    });
    final BiliCommentRepository repository = BiliCommentRepository(client);

    final CommentItem? created = await repository.addComment(
      target,
      message: '  你好  ',
    );

    expect(client.path, '/x/v2/reply/add');
    expect(client.data, <String, dynamic>{
      'type': 1,
      'oid': 100,
      'message': '你好',
      'plat': 1,
      'csrf': 'csrf',
    });
    expect(created?.rpid, 55);
    expect(created?.message, '你好');
    expect(created?.isLiked, isTrue);
  });

  test('addComment 在服务端未回传评论时返回 null', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 0,
      'data': <String, dynamic>{'rpid': 55, 'reply': null},
    });
    final BiliCommentRepository repository = BiliCommentRepository(client);

    expect(await repository.addComment(target, message: '你好'), isNull);
  });

  test('addComment 遇到验证码要求时明确提示', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 0,
      'data': <String, dynamic>{'need_captcha': true},
    });
    final BiliCommentRepository repository = BiliCommentRepository(client);

    await expectLater(
      repository.addComment(target, message: '你好'),
      throwsA(isA<BiliCommentException>()),
    );
  });

  test('未登录时不发请求', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
      'code': 0,
    }, session: null);
    final BiliCommentRepository repository = BiliCommentRepository(client);

    await expectLater(
      repository.likeComment(target, rpid: 9, liked: true),
      throwsA(isA<BiliCommentException>()),
    );
    expect(client.path, isNull);
  });
}

class _FakeBiliHttpClient implements BiliHttpClient {
  _FakeBiliHttpClient(this.response, {this.session = _session});

  final Map<String, dynamic> response;
  final BiliSession? session;

  String? path;
  Map<String, dynamic>? data;
  String? contentType;

  @override
  BiliSession? get currentSession => session;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    this.path = path;
    this.data = (data as Map<dynamic, dynamic>).cast<String, dynamic>();
    contentType = options?.contentType;
    return Response<T>(
      data: response as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const BiliSession _session = BiliSession(
  sessData: 'sess',
  biliJct: 'csrf',
  dedeUserId: '1',
  refreshToken: '',
  cookie: 'SESSDATA=sess',
);
