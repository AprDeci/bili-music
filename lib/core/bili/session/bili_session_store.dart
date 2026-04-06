import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_session_store.g.dart';

@riverpod
BiliSessionStore biliSessionStore(Ref ref) {
  return BiliSessionStore(Hive.box<String>(HiveBoxNames.prefs));
}

class BiliSessionStore {
  const BiliSessionStore(this._prefsBox);

  final Box<String> _prefsBox;

  Future<void> save(BiliSession session) {
    return Future.wait(<Future<void>>[
      _prefsBox.put(HiveKeys.biliCookie, session.cookie),
      _prefsBox.put(HiveKeys.biliSessData, session.sessData),
      _prefsBox.put(HiveKeys.biliJct, session.biliJct),
      _prefsBox.put(HiveKeys.biliDedeUserId, session.dedeUserId),
      _prefsBox.put(HiveKeys.biliRefreshToken, session.refreshToken),
      _prefsBox.put(HiveKeys.biliMid, session.mid?.toString() ?? ''),
      _prefsBox.put(HiveKeys.biliUname, session.uname ?? ''),
      _prefsBox.put(HiveKeys.biliFace, session.face ?? ''),
      _prefsBox.put(HiveKeys.biliImgKey, session.imgKey ?? ''),
      _prefsBox.put(HiveKeys.biliSubKey, session.subKey ?? ''),
      _prefsBox.put(HiveKeys.biliBuvid3, session.buvid3 ?? ''),
    ]);
  }

  BiliSession? load() {
    final String cookie =
        _prefsBox.get(HiveKeys.biliCookie, defaultValue: '') ?? '';
    if (cookie.isEmpty) {
      return null;
    }

    final String midValue =
        _prefsBox.get(HiveKeys.biliMid, defaultValue: '') ?? '';
    return BiliSession(
      sessData: _prefsBox.get(HiveKeys.biliSessData, defaultValue: '') ?? '',
      biliJct: _prefsBox.get(HiveKeys.biliJct, defaultValue: '') ?? '',
      dedeUserId:
          _prefsBox.get(HiveKeys.biliDedeUserId, defaultValue: '') ?? '',
      refreshToken:
          _prefsBox.get(HiveKeys.biliRefreshToken, defaultValue: '') ?? '',
      cookie: cookie,
      mid: int.tryParse(midValue),
      uname: _prefsBox.get(HiveKeys.biliUname, defaultValue: ''),
      face: _prefsBox.get(HiveKeys.biliFace, defaultValue: ''),
      imgKey: _prefsBox.get(HiveKeys.biliImgKey, defaultValue: ''),
      subKey: _prefsBox.get(HiveKeys.biliSubKey, defaultValue: ''),
      buvid3: _prefsBox.get(HiveKeys.biliBuvid3, defaultValue: ''),
    );
  }

  Future<void> clear() {
    return Future.wait(<Future<void>>[
      _prefsBox.delete(HiveKeys.biliCookie),
      _prefsBox.delete(HiveKeys.biliSessData),
      _prefsBox.delete(HiveKeys.biliJct),
      _prefsBox.delete(HiveKeys.biliDedeUserId),
      _prefsBox.delete(HiveKeys.biliRefreshToken),
      _prefsBox.delete(HiveKeys.biliMid),
      _prefsBox.delete(HiveKeys.biliUname),
      _prefsBox.delete(HiveKeys.biliFace),
      _prefsBox.delete(HiveKeys.biliImgKey),
      _prefsBox.delete(HiveKeys.biliSubKey),
      _prefsBox.delete(HiveKeys.biliBuvid3),
    ]);
  }
}
