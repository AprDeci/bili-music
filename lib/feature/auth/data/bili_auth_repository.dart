import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/session/bili_cookie.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BiliAuthRepository {
  const BiliAuthRepository(this._client);

  final BiliHttpClient _client;
  static const String _passportBaseUrl = 'https://passport.bilibili.com';
  static const String _mainlandCid = '1';
  static const String _loginSource = 'main_web';

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

    final Map<String, String> cookies = extractCookiesFromHeaders(
      response.headers,
    );
    final String sessData = cookies['SESSDATA'] ?? '';
    final String biliJct = cookies['bili_jct'] ?? '';
    final String dedeUserId = cookies['DedeUserID'] ?? '';
    final String refreshToken = data['refresh_token'] as String? ?? '';

    if (sessData.isEmpty || biliJct.isEmpty || dedeUserId.isEmpty) {
      throw const BiliAuthException(
        'Login succeeded, but cookies are missing.',
      );
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

  Future<BiliCaptchaParams> fetchCaptcha() async {
    final Response<dynamic> response = await _client.get<dynamic>(
      '$_passportBaseUrl/x/passport-login/captcha',
      queryParameters: <String, dynamic>{'source': _loginSource},
    );
    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> geetest = _asMap(data['geetest']);
    final BiliCaptchaParams params = BiliCaptchaParams(
      token: data['token'] as String? ?? '',
      gt: geetest['gt'] as String? ?? '',
      challenge: geetest['challenge'] as String? ?? '',
    );

    if (params.token.isEmpty || params.gt.isEmpty || params.challenge.isEmpty) {
      throw const BiliAuthException('人机验证参数获取失败，请稍后重试。');
    }

    return params;
  }

  Future<BiliSmsSendResult> sendSmsCode({
    required String tel,
    required BiliCaptchaParams captcha,
    required BiliGeetestResult geetest,
  }) async {
    final Response<dynamic> response = await _client.post<dynamic>(
      '$_passportBaseUrl/x/passport-login/web/sms/send',
      data: <String, dynamic>{
        'cid': _mainlandCid,
        'tel': tel,
        'source': _loginSource,
        'token': captcha.token,
        'challenge': geetest.challenge,
        'validate': geetest.validate,
        'seccode': geetest.seccode,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final Map<String, dynamic>? json = _tryAsMap(response.data);
    if (json == null) {
      return const BiliSmsSendResult(code: -1, message: '验证码接口返回了无法解析的内容。');
    }

    final Map<String, dynamic>? data = _tryAsMap(json['data']);
    final int code = (json['code'] as num? ?? -1).toInt();
    final String? captchaKey = data?['captcha_key'] as String?;
    debugPrint(
      '[BiliSms] send code=$code message=${json['message']} '
      'captchaKey=${captchaKey != null}',
    );
    if (code == 0 && (captchaKey == null || captchaKey.isEmpty)) {
      throw const BiliAuthException('短信接口未返回登录密钥，请重新获取验证码。');
    }

    return BiliSmsSendResult(
      code: code,
      message: json['message'] as String? ?? '',
      captchaKey: captchaKey,
    );
  }

  Future<BiliSmsLoginResult> loginBySmsCode({
    required String tel,
    required String code,
    required String captchaKey,
  }) async {
    final Response<dynamic> response = await _client.post<dynamic>(
      '$_passportBaseUrl/x/passport-login/web/login/sms',
      data: <String, dynamic>{
        'cid': _mainlandCid,
        'tel': tel,
        'code': code,
        'source': _loginSource,
        'captcha_key': captchaKey,
        'keep': 'true',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final Map<String, dynamic>? json = _tryAsMap(response.data);
    if (json == null) {
      return const BiliSmsLoginResult(code: -1, message: '登录接口返回了无法解析的内容。');
    }

    final int responseCode = (json['code'] as num? ?? -1).toInt();
    final String message = json['message'] as String? ?? '';
    debugPrint('[BiliSms] login code=$responseCode message=$message');
    if (responseCode != 0) {
      return BiliSmsLoginResult(code: responseCode, message: message);
    }

    final Map<String, String> cookies = extractCookiesFromHeaders(
      response.headers,
    );
    final String sessData = cookies['SESSDATA'] ?? '';
    final String biliJct = cookies['bili_jct'] ?? '';
    final String dedeUserId = cookies['DedeUserID'] ?? '';
    if (sessData.isEmpty || biliJct.isEmpty || dedeUserId.isEmpty) {
      throw const BiliAuthException('登录成功，但响应中缺少登录 Cookie。');
    }

    final Map<String, dynamic>? data = _tryAsMap(json['data']);
    return BiliSmsLoginResult(
      code: 0,
      message: message,
      session: BiliSession(
        sessData: sessData,
        biliJct: biliJct,
        dedeUserId: dedeUserId,
        refreshToken: data?['refresh_token'] as String? ?? '',
        cookie: buildCookieHeader(cookies),
      ),
    );
  }

  Future<LogoutResult> logout(BiliSession session) async {
    if (!session.isLoggedIn) {
      return const LogoutResult(remoteLoggedOut: false, message: '当前没有可注销的登录态');
    }

    try {
      final Response<dynamic> response = await _client.post<dynamic>(
        '$_passportBaseUrl/login/exit/v2',
        data:
            'biliCSRF=${Uri.encodeQueryComponent(session.biliJct)}&gourl=${Uri.encodeQueryComponent('https://www.bilibili.com/')}',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: <String, dynamic>{'Cookie': session.cookie},
        ),
      );
      final Map<String, dynamic>? json = _tryAsMap(response.data);
      if (json == null) {
        return _resolveLogoutFromHeaders(response.headers);
      }

      final int code = (json['code'] as num? ?? -1).toInt();
      final bool status = json['status'] as bool? ?? false;
      if (code == 0 && status) {
        return const LogoutResult(remoteLoggedOut: true);
      }

      return LogoutResult(
        remoteLoggedOut: false,
        message: json['message'] as String? ?? '退出登录失败',
      );
    } on Object catch (error) {
      return LogoutResult(remoteLoggedOut: false, message: error.toString());
    }
  }

  LogoutResult _resolveLogoutFromHeaders(Headers headers) {
    final List<String> setCookieHeaders =
        headers['set-cookie'] ?? headers.map['set-cookie'] ?? const <String>[];
    final bool clearedAuthCookies =
        setCookieHeaders.any((String header) => header.contains('SESSDATA=')) &&
        setCookieHeaders.any((String header) => header.contains('bili_jct=')) &&
        setCookieHeaders.any((String header) => header.contains('DedeUserID='));

    if (clearedAuthCookies) {
      return const LogoutResult(remoteLoggedOut: true);
    }

    return const LogoutResult(
      remoteLoggedOut: false,
      message: '退出接口未返回可识别的成功结果',
    );
  }

  Map<String, dynamic>? _tryAsMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      try {
        final dynamic decoded = jsonDecode(trimmed);
        return _asMap(decoded);
      } on FormatException {
        return null;
      }
    }

    try {
      return _asMap(value);
    } on BiliAuthException {
      return null;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliAuthException('Unexpected response format.');
    }
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

class BiliSmsSendResult {
  const BiliSmsSendResult({
    required this.code,
    required this.message,
    this.captchaKey,
  });

  final int code;
  final String message;
  final String? captchaKey;
}

class BiliSmsLoginResult {
  const BiliSmsLoginResult({
    required this.code,
    required this.message,
    this.session,
  });

  final int code;
  final String message;
  final BiliSession? session;
}

class LogoutResult {
  const LogoutResult({required this.remoteLoggedOut, this.message});

  final bool remoteLoggedOut;
  final String? message;
}

class BiliAuthException implements Exception {
  const BiliAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
