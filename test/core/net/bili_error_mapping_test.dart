import 'package:bilimusic/core/bili/session/bili_auth_required_exception.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('biliApiErrorFromCode', () {
    test('未登录时的鉴权类错误码统一为需要登录', () {
      for (final int code in <int>[-101, -352, -403]) {
        expect(
          biliApiErrorFromCode(code, loggedIn: false),
          isA<BiliAuthRequiredException>(),
          reason: 'code=$code',
        );
      }
    });

    test('已登录时保持原样，不把风控误报成需要登录', () {
      final Exception error = biliApiErrorFromCode(
        -352,
        loggedIn: true,
        message: '风控校验失败',
      );

      expect(error, isA<BiliApiException>());
      expect((error as BiliApiException).code, -352);
    });

    test('普通错误码仍是 BiliApiException', () {
      final Exception error = biliApiErrorFromCode(-404, loggedIn: false);

      expect(error, isA<BiliApiException>());
      expect((error as BiliApiException).code, -404);
    });
  });
}
