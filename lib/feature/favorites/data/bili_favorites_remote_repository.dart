import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';

class BiliFavoritesRemoteRepository {
  const BiliFavoritesRemoteRepository({required this.client});

  final BiliHttpClient client;
  static final AppLogger _logger = AppLogger('BiliFavorites');

  Future<List<FavoriteCollection>> fetchCreatedCollections({
    required BiliSession session,
  }) async {
    _ensureLoggedIn(session);
    final int mid = session.mid ?? int.tryParse(session.dedeUserId) ?? 0;
    if (mid <= 0) {
      throw const BiliFavoritesException(
        'Missing user mid for favorite collection request.',
      );
    }
    final Response<dynamic> response = await client.get<dynamic>(
      '/x/v3/fav/folder/created/list-all',
      queryParameters: <String, dynamic>{
        'up_mid': mid,
        'web_location': '333.1387',
      },
      options: Options(headers: <String, dynamic>{'Cookie': session.cookie}),
    );
    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic>? data = asNullableStringKeyedMap(json['data']);
    if (data == null) {
      _logger.w('created/list-all returned null data for mid=$mid: $json');
      throw const BiliFavoritesException(
        'Bilibili returned no favorite collection data.',
      );
    }
    _logger.d(
      'created/list-all mid=$mid count=${data['count']} listType=${data['list']?.runtimeType}',
    );
    final List<Map<String, dynamic>> list = asListOfMaps(data['list']);
    return list.map(_mapCollection).toList(growable: false);
  }

  Future<BiliFavoriteCollectionPage> fetchCollectionPage({
    required BiliSession session,
    required String remoteId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    _ensureLoggedIn(session);
    final Response<dynamic> response = await client.get<dynamic>(
      '/x/v3/fav/resource/list',
      queryParameters: <String, dynamic>{
        'media_id': remoteId,
        'platform': 'web',
        'pn': pageNumber,
        'ps': pageSize.clamp(1, 20),
      },
      options: Options(headers: <String, dynamic>{'Cookie': session.cookie}),
    );
    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    final Map<String, dynamic> data = _asMap(json['data']);
    final FavoriteCollection collection = _mapCollection(_asMap(data['info']));
    final List<FavoriteEntry> items = asListOfMaps(
      data['medias'],
    ).map(_mapEntry).whereType<FavoriteEntry>().toList(growable: false);
    return BiliFavoriteCollectionPage(
      collection: collection,
      items: items,
      hasMore: data['has_more'] as bool? ?? false,
      pageNumber: pageNumber,
    );
  }

  Future<FavoriteCollection> createCollection({
    required BiliSession session,
    required String name,
    bool private = true,
  }) async {
    final Map<String, dynamic> json = await _postForm(
      '/x/v3/fav/folder/add',
      data: <String, dynamic>{
        'title': name,
        'intro': '',
        'privacy': private ? 1 : 0,
      },
      session: session,
    );
    return _mapCollection(_asMap(json['data'])).copyWith(isManagedByApp: true);
  }

  Future<FavoriteCollection> renameCollection({
    required BiliSession session,
    required String remoteId,
    required String name,
    bool private = true,
  }) async {
    final Map<String, dynamic> json = await _postForm(
      '/x/v3/fav/folder/edit',
      data: <String, dynamic>{
        'media_id': remoteId,
        'title': name,
        'intro': '',
        'privacy': private ? 1 : 0,
      },
      session: session,
    );
    return _mapCollection(_asMap(json['data'])).copyWith(isManagedByApp: true);
  }

  Future<void> deleteCollection({
    required BiliSession session,
    required String remoteId,
  }) async {
    await _postForm(
      '/x/v3/fav/folder/del',
      data: <String, dynamic>{'media_ids': remoteId},
      session: session,
    );
  }

  Future<void> addVideoToCollection({
    required BiliSession session,
    required String remoteId,
    required PlayableItem item,
  }) async {
    final int aid = _requireAid(item);
    await _postForm(
      '/x/v3/fav/resource/deal',
      data: <String, dynamic>{
        'rid': aid,
        'type': 2,
        'add_media_ids': remoteId,
        'del_media_ids': '',
      },
      session: session,
    );
  }

  Future<void> removeVideoFromCollection({
    required BiliSession session,
    required String remoteId,
    required int aid,
  }) async {
    if (aid <= 0) {
      throw const BiliFavoritesException('Missing aid for favorite removal.');
    }
    await _postForm(
      '/x/v3/fav/resource/batch-del',
      data: <String, dynamic>{
        'resources': '$aid:2',
        'media_id': remoteId,
        'platform': 'web',
      },
      session: session,
    );
  }

  Future<Map<String, dynamic>> _postForm(
    String path, {
    required Map<String, dynamic> data,
    required BiliSession session,
  }) async {
    _ensureLoggedIn(session);
    final Map<String, dynamic> formData = <String, dynamic>{
      ...data,
      'csrf': session.biliJct,
    };
    final Response<dynamic> response = await client.post<dynamic>(
      path,
      data: formData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: <String, dynamic>{'Cookie': session.cookie},
      ),
    );
    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    return json;
  }

  FavoriteCollection _mapCollection(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    final String remoteId = _readString(json['id']);
    return FavoriteCollection(
      id: FavoriteCollection.remoteCollectionId(remoteId),
      name: _readString(json['title']),
      source: FavoriteCollectionSource.remote,
      remoteId: remoteId,
      coverUrl: _readNullableString(json['cover']),
      itemCount: (json['media_count'] as num? ?? 0).toInt(),
      isSystem: false,
      isManagedByApp: false,
      createdAt: _readTimestamp(json['ctime']) ?? now,
      updatedAt: _readTimestamp(json['mtime']) ?? now,
      lastSyncedAt: now,
    );
  }

  FavoriteEntry? _mapEntry(Map<String, dynamic> json) {
    final int type = (json['type'] as num? ?? 0).toInt();
    if (type != 2) {
      return null;
    }
    final int aid = (json['id'] as num? ?? 0).toInt();
    final String bvid =
        _readNullableString(json['bvid']) ??
        _readNullableString(json['bv_id']) ??
        '';
    if (aid <= 0 && bvid.isEmpty) {
      return null;
    }
    final Map<String, dynamic> upper = asStringKeyedMapOrEmpty(json['upper']);
    final DateTime now = DateTime.now();
    final DateTime favTime = _readTimestamp(json['fav_time']) ?? now;
    final PlayableItem item = PlayableItem(
      aid: aid,
      bvid: bvid,
      title: _readString(json['title']),
      author: _readString(upper['name']),
      coverUrl: _readString(json['cover']),
      ownerMid: _readInt(upper['mid']),
      page: 1,
      durationText: _formatDuration((json['duration'] as num?)?.toInt()),
    );
    return FavoriteEntry.fromPlayableItem(
      item,
      now: favTime,
    ).copyWith(updatedAt: now);
  }

  void _ensureLoggedIn(BiliSession session) {
    if (!session.isLoggedIn) {
      throw const BiliFavoritesException('Bilibili session is required.');
    }
  }

  int _requireAid(PlayableItem item) {
    if (item.aid <= 0) {
      throw const BiliFavoritesException('Missing aid for favorite request.');
    }
    return item.aid;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliFavoritesException(
        'Unexpected favorite response format.',
      );
    }
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    final int code = (json['code'] as num? ?? -1).toInt();
    if (code != 0) {
      throw BiliFavoritesException(
        json['message'] as String? ?? 'Favorite request failed.',
        code: code,
      );
    }
  }

  String _readString(dynamic value) => _readNullableString(value) ?? '';

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String? _readNullableString(dynamic value) {
    final String? text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  DateTime? _readTimestamp(dynamic value) {
    final int seconds = (value as num? ?? 0).toInt();
    if (seconds <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  String? _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) {
      return null;
    }
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class BiliFavoritesException implements Exception {
  const BiliFavoritesException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}
