import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_session_store.g.dart';

@riverpod
BiliSessionStore biliSessionStore(Ref ref) {
  return BiliSessionStore(Hive.box<String>('prefs'));
}

class BiliSessionStore {
  const BiliSessionStore(this._prefsBox);

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
  static const String _buvid3Key = 'bili.buvid3';

  Future<void> save(BiliSession session) {
    return Future.wait(<Future<void>>[
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
      _prefsBox.put(_buvid3Key, session.buvid3 ?? ''),
    ]);
  }

  BiliSession? load() {
    final String cookie = _prefsBox.get(_cookieKey, defaultValue: '') ?? '';
    if (cookie.isEmpty) {
      return null;
    }

    final String midValue = _prefsBox.get(_midKey, defaultValue: '') ?? '';
    return BiliSession(
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
      buvid3: _prefsBox.get(_buvid3Key, defaultValue: ''),
    );
  }

  Future<void> clear() {
    return Future.wait(<Future<void>>[
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
      _prefsBox.delete(_buvid3Key),
    ]);
  }
}
