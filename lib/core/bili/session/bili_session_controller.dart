import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_store.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_session_controller.g.dart';

@riverpod
class BiliSessionController extends _$BiliSessionController {
  late final BiliSessionStore _store = ref.read(biliSessionStoreProvider);
  late final BiliClient _client = ref.read(biliClientProvider.notifier);

  @override
  BiliSession? build() {
    final BiliSession? session = _store.load();
    if (session != null && session.hasCookie) {
      _client.setCookie(session.cookie);
    } else {
      _client.clearCookie();
    }
    return session;
  }

  Future<void> setSession(BiliSession session) async {
    _client.setCookie(session.cookie);
    await _store.save(session);
    state = session;
  }

  Future<void> clearSession() async {
    await _store.clear();
    _client.clearCookie();
    state = null;
  }
}
