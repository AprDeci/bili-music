import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_cookie.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:dio/dio.dart';

class BiliAuthRepository {
  const BiliAuthRepository(this._client);

  final BiliClient _client;
  static const String _passportBaseUrl = 'https://passport.bilibili.com';

  Future<BiliQrCodeSession> generateQrCode() async {
    final Response<dynamic> response = await _client.get<dynamic>(
      '$_passportBaseUrl/x/passport-login/web/qrcode/generate',
    );
    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic> data = _asMap(json['data']);
    return BiliQrCodeSession(
      url: data['url'] as String? ?? '',
      qrcodeKey: data['qrcode_key'] as String? ?? '',
    );
  }

  Future<PollQrCodeResult> pollQrCode(String qrcodeKey) async {
    final Response<dynamic> response = await _client.get<dynamic>(
      '$_passportBaseUrl/x/passport-login/web/qrcode/poll',
      queryParameters: <String, dynamic>{'qrcode_key': qrcodeKey},
    );

    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic> data = _asMap(json['data']);
    final int code = (data['code'] as num? ?? -1).toInt();
    final String message = data['message'] as String? ?? 'Unknown login state';

    if (code != 0) {
      return PollQrCodeResult(code: code, message: message);
    }

    final Map<String, String> cookies = extractCookiesFromHeaders(response.headers);
    final String sessData = cookies['SESSDATA'] ?? '';
    final String biliJct = cookies['bili_jct'] ?? '';
    final String dedeUserId = cookies['DedeUserID'] ?? '';
    final String refreshToken = data['refresh_token'] as String? ?? '';

    if (sessData.isEmpty || biliJct.isEmpty || dedeUserId.isEmpty) {
      throw const BiliAuthException('Login succeeded, but cookies are missing.');
    }

    final String cookie = buildCookieHeader(cookies);
    return PollQrCodeResult(
      code: code,
      message: message,
      session: BiliSession(
        sessData: sessData,
        biliJct: biliJct,
        dedeUserId: dedeUserId,
        refreshToken: refreshToken,
        cookie: cookie,
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) =>
            MapEntry(key.toString(), mapValue),
      );
    }
    throw const BiliAuthException('Unexpected response format.');
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    final int code = (json['code'] as num? ?? -1).toInt();
    if (code != 0) {
      throw BiliAuthException(json['message'] as String? ?? 'Request failed.');
    }
  }
}

class PollQrCodeResult {
  const PollQrCodeResult({
    required this.code,
    required this.message,
    this.session,
  });

  final int code;
  final String message;
  final BiliSession? session;
}

class BiliAuthException implements Exception {
  const BiliAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
