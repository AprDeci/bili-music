import 'dart:async';

import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';

class BiliAuthRepository {
  const BiliAuthRepository(this._client, this._prefsBox);

  final BiliClient _client;
  final Box<String> _prefsBox;

  static const String _cookieKey = 'bili.cookie';
  static const String _sessDataKey = 'bili.sessdata';
  static const String _biliJctKey = 'bili.bili_jct';
  static const String _dedeUserIdKey = 'bili.dede_user_id';
  static const String _refreshTokenKey = 'bili.refresh_token';
  static const String _midKey = 'bili.mid';
  static const String _unameKey = 'bili.uname';
  static const String _faceKey = 'bili.face';
  static const String _imgKey = 'bili.img_key';
  static const String _subKey = 'bili.sub_key';
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

    final Map<String, String> cookies = _extractCookies(response.headers);
    final String sessData = cookies['SESSDATA'] ?? '';
    final String biliJct = cookies['bili_jct'] ?? '';
    final String dedeUserId = cookies['DedeUserID'] ?? '';
    final String refreshToken = data['refresh_token'] as String? ?? '';

    if (sessData.isEmpty || biliJct.isEmpty || dedeUserId.isEmpty) {
      throw const BiliAuthException('Login succeeded, but cookies are missing.');
    }

    final String cookie = _buildCookie(cookies);
    return PollQrCodeResult(
      code: code,
      message: message,
      session: BiliAuthSession(
        sessData: sessData,
        biliJct: biliJct,
        dedeUserId: dedeUserId,
        refreshToken: refreshToken,
        cookie: cookie,
      ),
    );
  }

  Future<BiliAuthSession> enrichSession(BiliAuthSession session) async {
    _client.setCookie(session.cookie);
    final Response<dynamic> response = await _client.get<dynamic>(
      '/x/web-interface/nav',
    );

    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic> data = _asMap(json['data']);
    final bool isLogin = data['isLogin'] as bool? ?? false;

    if (!isLogin) {
      throw const BiliAuthException('Cookie is not valid after QR login.');
    }

    final Map<String, dynamic> wbiImg = _asMap(data['wbi_img']);
    return session.copyWith(
      mid: (data['mid'] as num?)?.toInt(),
      uname: data['uname'] as String?,
      face: data['face'] as String?,
      imgKey: _extractKeyFromUrl(wbiImg['img_url'] as String?),
      subKey: _extractKeyFromUrl(wbiImg['sub_url'] as String?),
    );
  }

  Future<void> saveSession(BiliAuthSession session) async {
    _client.setCookie(session.cookie);
    await Future.wait(<Future<void>>[
      _prefsBox.put(_cookieKey, session.cookie),
      _prefsBox.put(_sessDataKey, session.sessData),
      _prefsBox.put(_biliJctKey, session.biliJct),
      _prefsBox.put(_dedeUserIdKey, session.dedeUserId),
      _prefsBox.put(_refreshTokenKey, session.refreshToken),
      _prefsBox.put(_midKey, session.mid?.toString() ?? ''),
      _prefsBox.put(_unameKey, session.uname ?? ''),
      _prefsBox.put(_faceKey, session.face ?? ''),
      _prefsBox.put(_imgKey, session.imgKey ?? ''),
      _prefsBox.put(_subKey, session.subKey ?? ''),
    ]);
  }

  BiliAuthSession? loadSession() {
    final String cookie = _prefsBox.get(_cookieKey, defaultValue: '') ?? '';
    if (cookie.isEmpty) {
      return null;
    }

    final String midValue = _prefsBox.get(_midKey, defaultValue: '') ?? '';
    return BiliAuthSession(
      sessData: _prefsBox.get(_sessDataKey, defaultValue: '') ?? '',
      biliJct: _prefsBox.get(_biliJctKey, defaultValue: '') ?? '',
      dedeUserId: _prefsBox.get(_dedeUserIdKey, defaultValue: '') ?? '',
      refreshToken: _prefsBox.get(_refreshTokenKey, defaultValue: '') ?? '',
      cookie: cookie,
      mid: int.tryParse(midValue),
      uname: _prefsBox.get(_unameKey, defaultValue: ''),
      face: _prefsBox.get(_faceKey, defaultValue: ''),
      imgKey: _prefsBox.get(_imgKey, defaultValue: ''),
      subKey: _prefsBox.get(_subKey, defaultValue: ''),
    );
  }

  void applySession(BiliAuthSession session) {
    _client.setCookie(session.cookie);
  }

  Future<void> clearSession() async {
    await Future.wait(<Future<void>>[
      _prefsBox.delete(_cookieKey),
      _prefsBox.delete(_sessDataKey),
      _prefsBox.delete(_biliJctKey),
      _prefsBox.delete(_dedeUserIdKey),
      _prefsBox.delete(_refreshTokenKey),
      _prefsBox.delete(_midKey),
      _prefsBox.delete(_unameKey),
      _prefsBox.delete(_faceKey),
      _prefsBox.delete(_imgKey),
      _prefsBox.delete(_subKey),
    ]);
    _client.clearCookie();
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

  Map<String, String> _extractCookies(Headers headers) {
    final List<String> setCookies = headers.map['set-cookie'] ?? <String>[];
    final Map<String, String> cookies = <String, String>{};

    for (final String item in setCookies) {
      final String pair = item.split(';').first.trim();
      final int separator = pair.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final String name = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (name.isNotEmpty && value.isNotEmpty) {
        cookies[name] = value;
      }
    }

    return cookies;
  }

  String _buildCookie(Map<String, String> cookies) {
    return cookies.entries
        .map((MapEntry<String, String> item) => '${item.key}=${item.value}')
        .join('; ');
  }

  String? _extractKeyFromUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    final Uri uri = Uri.parse(url);
    final String lastSegment = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last;
    final int dotIndex = lastSegment.lastIndexOf('.');
    return dotIndex > 0 ? lastSegment.substring(0, dotIndex) : lastSegment;
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
  final BiliAuthSession? session;
}

class BiliAuthException implements Exception {
  const BiliAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
