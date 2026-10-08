import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiliSessionController.parseWbiKeys', () {
    test('游客 nav 响应 code=-101 仍能解析出 WBI 密钥', () {
      final ({String imgKey, String subKey})? keys = BiliSessionController
          .parseWbiKeys(<String, dynamic>{
            'code': -101,
            'message': '账号未登录',
            'data': <String, dynamic>{
              'isLogin': false,
              'wbi_img': <String, dynamic>{
                'img_url':
                    'https://i0.hdslb.com/bfs/wbi/7cd084941338484aae1ad9425b84077c.png',
                'sub_url':
                    'https://i0.hdslb.com/bfs/wbi/4932caff0ff746eab6f01bf08b70ac45.png',
              },
            },
          });

      expect(keys?.imgKey, '7cd084941338484aae1ad9425b84077c');
      expect(keys?.subKey, '4932caff0ff746eab6f01bf08b70ac45');
    });

    test('缺少 wbi_img 时返回 null', () {
      expect(
        BiliSessionController.parseWbiKeys(const <String, dynamic>{
          'code': -101,
        }),
        isNull,
      );
      expect(
        BiliSessionController.parseWbiKeys(const <String, dynamic>{
          'code': 0,
          'data': <String, dynamic>{},
        }),
        isNull,
      );
    });
  });
}
