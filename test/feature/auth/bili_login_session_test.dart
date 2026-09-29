import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/auth/data/bili_login_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('三个必需 Cookie 齐全时构造出登录态', () {
    final BiliSession? session = sessionFromCookies(<String, String>{
      'SESSDATA': 'sess-value',
      'bili_jct': 'jct-value',
      'DedeUserID': '42',
      'buvid3': 'buvid-value',
    });

    expect(session, isNotNull);
    expect(session!.sessData, 'sess-value');
    expect(session.biliJct, 'jct-value');
    expect(session.dedeUserId, '42');
    expect(session.buvid3, 'buvid-value');
    expect(session.isLoggedIn, isTrue);
    expect(session.cookie, contains('SESSDATA=sess-value'));
    expect(session.cookie, contains('bili_jct=jct-value'));
    expect(session.cookie, contains('DedeUserID=42'));
    expect(session.cookie, contains('buvid3=buvid-value'));
  });

  test('缺少任意一个必需 Cookie 都返回 null', () {
    const Map<String, String> complete = <String, String>{
      'SESSDATA': 'sess-value',
      'bili_jct': 'jct-value',
      'DedeUserID': '42',
    };

    for (final String missing in <String>[
      'SESSDATA',
      'bili_jct',
      'DedeUserID',
    ]) {
      final Map<String, String> cookies = Map<String, String>.from(complete)
        ..remove(missing);
      expect(
        sessionFromCookies(cookies),
        isNull,
        reason: '缺少 $missing 时应视为未登录完成',
      );
    }
  });

  test('空 Cookie 返回 null 且不依赖 buvid3', () {
    expect(sessionFromCookies(<String, String>{}), isNull);

    final BiliSession? session = sessionFromCookies(<String, String>{
      'SESSDATA': 's',
      'bili_jct': 'j',
      'DedeUserID': '1',
    });
    expect(session, isNotNull);
    expect(session!.buvid3, isNull);
    expect(session.refreshToken, '');
  });
}
