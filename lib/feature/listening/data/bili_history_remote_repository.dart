import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';

class BiliHistoryRemoteRepository {
  const BiliHistoryRemoteRepository(this._client);

  final BiliHttpClient _client;

  Future<ListeningProgress?> fetchProgress(
    PlayableItem item,
    BiliSession session,
  ) async {
    _requireSession(session);
    if (!item.hasIdentity ||
        item.aid < 0 ||
        (item.page ?? 1) <= 0 ||
        (item.cid ?? 0) <= 0) {
      return null;
    }
    final Map<String, dynamic> json = await _client.getJson(
      '/x/player/v2',
      queryParameters: {
        if (item.aid > 0) 'aid': item.aid,
        if (item.bvid.isNotEmpty) 'bvid': item.bvid,
        'cid': item.cid,
      },
      requiresAuth: true,
      options: _options(session),
    );
    final Map<String, dynamic> data = asStringKeyedMap(json['data']);
    final int cid = _integer(data['last_play_cid']);
    final int? position = _position(data['last_play_time']);
    if (cid <= 0 || position == null) return null;
    return ListeningProgress(
      accountId: session.dedeUserId,
      aid: item.aid,
      bvid: item.bvid,
      cid: cid,
      page: item.page ?? 1,
      positionMs: position < 0 ? 0 : position,
      completed: position == -1,
    );
  }

  Future<List<ListeningProgress>> fetchRecent(
    BiliSession session, {
    Set<String>? videoIds,
  }) async {
    _requireSession(session);
    final List<ListeningProgress> result = [];
    final Set<String> seenCursors = {};
    Map<String, dynamic> cursor = {};
    while (true) {
      final Map<String, dynamic> json = await _client.getJson(
        '/x/web-interface/history/cursor',
        queryParameters: {'type': 'archive', 'ps': 30, ...cursor},
        requiresAuth: true,
        options: _options(session),
      );
      final Map<String, dynamic> data = asStringKeyedMap(json['data']);
      final Object? rows = data['list'];
      if (rows is! List) throw const FormatException('历史记录格式异常');
      if (rows.isEmpty) break;
      for (final Object? value in rows) {
        final Map<String, dynamic> row = asStringKeyedMap(value);
        final Map<String, dynamic> history = asStringKeyedMap(row['history']);
        if (history['business'] != 'archive') continue;
        final int aid = _integer(history['oid']);
        final String bvid = history['bvid'] is String
            ? history['bvid'] as String
            : '';
        final int cid = _integer(history['cid']);
        final int? progress = _position(row['progress']);
        final int viewedAt = _integer(row['view_at']);
        final int duration = _integer(row['duration']);
        if (cid <= 0 || progress == null || viewedAt <= 0) continue;
        final ListeningProgress entry = ListeningProgress(
          accountId: session.dedeUserId,
          aid: aid,
          bvid: bvid,
          cid: cid,
          page: _integer(history['page'], fallback: 1),
          positionMs: progress < 0 ? 0 : progress * 1000,
          durationMs: duration < 0 ? 0 : duration * 1000,
          updatedAtMs: viewedAt * 1000,
          completed: progress == -1,
        );
        if (entry.isValid &&
            (videoIds == null ||
                videoIds.contains(entry.videoId) ||
                videoIds.contains('aid:$aid'))) {
          result.add(entry);
        }
      }
      if (videoIds == null || result.isNotEmpty) break;
      final Map<String, dynamic> next = asStringKeyedMap(data['cursor']);
      cursor = {
        'max': _integer(next['max']),
        'view_at': _integer(next['view_at']),
        'business': next['business'] is String ? next['business'] : 'archive',
      };
      if (cursor['max'] == 0 ||
          !seenCursors.add(
            '${cursor['max']}:${cursor['view_at']}:${cursor['business']}',
          )) {
        break;
      }
    }
    return result;
  }

  Future<void> report(ListeningProgress progress, BiliSession session) async {
    _requireSession(session);
    if (!progress.isValid ||
        progress.aid <= 0 ||
        progress.accountId != session.dedeUserId) {
      throw const FormatException('收听进度账号不匹配');
    }
    final Response<dynamic> response = await _client.post<dynamic>(
      '/x/v2/history/report',
      data: {
        'aid': progress.aid,
        'cid': progress.cid,
        'progress': progress.completed ? -1 : progress.positionMs ~/ 1000,
        'platform': 'android',
        'csrf': session.biliJct,
      },
      options: _options(
        session,
      ).copyWith(contentType: Headers.formUrlEncodedContentType),
    );
    final Map<String, dynamic> json = asStringKeyedMap(response.data);
    final int code = _integer(json['code'], fallback: -1);
    if (code != 0) {
      throw BiliApiException(
        json['message'] is String ? json['message'] as String : '历史同步失败',
        code: code,
      );
    }
  }

  Options _options(BiliSession session) => Options(
    headers: {'Cookie': session.cookie},
    sendTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  );

  void _requireSession(BiliSession session) {
    if (!session.isLoggedIn ||
        _client.currentSession?.dedeUserId != session.dedeUserId ||
        !(_client.currentSession?.isLoggedIn ?? false)) {
      throw const BiliApiException('登录后可同步收听进度');
    }
  }
}

int? _position(Object? value) =>
    value is num && value.isFinite && (value >= 0 || value == -1)
    ? value.toInt()
    : null;

int _integer(Object? value, {int fallback = 0}) =>
    value is num && value.isFinite ? value.toInt() : fallback;
