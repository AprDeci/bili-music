import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/common/util/url_util.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/up/data/bili_up_exception.dart';
import 'package:bilimusic/feature/up/domain/collection_item_page_result.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_collection_item.dart';
import 'package:bilimusic/feature/up/domain/up_collection_page_result.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';
import 'package:bilimusic/feature/up/domain/up_video_page_result.dart';

class BiliUpRepository {
  const BiliUpRepository(this._client);

  static const int defaultPageSize = 20;

  final BiliHttpClient _client;

  Future<UpProfile> fetchProfile({required int mid}) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/web-interface/card',
      queryParameters: <String, dynamic>{'mid': mid},
    );
    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> card = _asMap(data['card']);
    final Map<String, dynamic>? officialVerify = _asNullableMap(
      card['official_verify'],
    );

    return UpProfile(
      mid: _readInt(card['mid']) ?? mid,
      name: (card['name'] as String? ?? '').trim(),
      avatarUrl: normalizeHttpUrl(card['face'] as String? ?? ''),
      followerCount: _readInt(data['follower']) ?? _readInt(card['fans']) ?? 0,
      officialType: _readInt(officialVerify?['type']),
    );
  }

  Future<UpVideoPageResult> fetchVideos({
    required int mid,
    required int page,
    int pageSize = defaultPageSize,
    String ownerName = '',
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/space/wbi/arc/search',
      queryParameters: <String, dynamic>{
        'mid': mid,
        'pn': page,
        'ps': pageSize,
        'order': 'pubdate',
      },
      requiresWbi: true,
    );
    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> list = _asMap(data['list']);
    final List<Map<String, dynamic>> rawItems = asListOfMaps(list['vlist']);
    final List<UpVideoItem> items = rawItems
        .map((Map<String, dynamic> item) => _mapVideo(item, mid, ownerName))
        .toList(growable: false);
    final Map<String, dynamic> pageInfo = _asMap(data['page']);
    final int resolvedPage = _readInt(pageInfo['pn']) ?? page;
    final int total = _readInt(pageInfo['count']) ?? items.length;
    final int resolvedPageSize = _readInt(pageInfo['ps']) ?? pageSize;

    return UpVideoPageResult(
      items: items,
      page: resolvedPage,
      hasMore: resolvedPage * resolvedPageSize < total,
    );
  }

  Future<UpCollectionPageResult> fetchCollections({
    required int mid,
    required int page,
    int pageSize = defaultPageSize,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/polymer/web-space/seasons_series_list',
      queryParameters: <String, dynamic>{
        'mid': mid,
        'page_num': page,
        'page_size': pageSize,
      },
      requiresWbi: true,
    );
    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> itemLists = _asMap(data['items_lists']);
    final List<Map<String, dynamic>> rawItems = asListOfMaps(
      itemLists['seasons_list'],
    );
    final List<UpCollection> items = rawItems
        .map(_mapCollectionListItem)
        .where((UpCollection item) => item.seasonId > 0)
        .toList(growable: false);
    final Map<String, dynamic> pageInfo = _asMap(itemLists['page']);
    final int resolvedPage =
        _readInt(pageInfo['page_num']) ?? _readInt(pageInfo['num']) ?? page;
    final int total = _readInt(pageInfo['total']) ?? items.length;
    final int resolvedPageSize =
        _readInt(pageInfo['page_size']) ??
        _readInt(pageInfo['size']) ??
        pageSize;

    return UpCollectionPageResult(
      items: items,
      page: resolvedPage,
      hasMore: resolvedPage * resolvedPageSize < total,
    );
  }

  Future<CollectionItemPageResult> fetchCollectionItems({
    required int mid,
    required int seasonId,
    required int page,
    int pageSize = defaultPageSize,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/polymer/web-space/seasons_archives_list',
      queryParameters: <String, dynamic>{
        'mid': mid,
        'season_id': seasonId,
        'page_num': page,
        'page_size': pageSize,
        'sort_reverse': false,
      },
      requiresWbi: true,
    );
    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> meta = _asMap(data['meta']);
    final UpCollection collection = _mapCollectionMeta(meta, fallbackMid: mid);
    final List<UpCollectionItem> items = asListOfMaps(
      data['archives'],
    ).map(_mapCollectionItem).toList(growable: false);
    final Map<String, dynamic> pageInfo = _asMap(data['page']);
    final int resolvedPage = _readInt(pageInfo['page_num']) ?? page;
    final int total = _readInt(pageInfo['total']) ?? items.length;
    final int resolvedPageSize = _readInt(pageInfo['page_size']) ?? pageSize;

    return CollectionItemPageResult(
      collection: collection,
      items: items,
      page: resolvedPage,
      hasMore: resolvedPage * resolvedPageSize < total,
    );
  }

  UpVideoItem _mapVideo(
    Map<String, dynamic> json,
    int fallbackMid,
    String fallbackOwnerName,
  ) {
    final int created =
        _readInt(json['created']) ?? _readInt(json['pubdate']) ?? 0;
    final int playCount = _readInt(json['play']) ?? 0;
    final int danmakuCount = _readInt(json['video_review']) ?? 0;
    final String ownerName = (json['author'] as String? ?? fallbackOwnerName)
        .trim();

    return UpVideoItem(
      aid: _readInt(json['aid']) ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: (json['title'] as String? ?? '').trim(),
      coverUrl: normalizeHttpUrl(json['pic'] as String? ?? ''),
      durationText: json['length'] as String? ?? '--:--',
      playCountText: formatCompactCount(playCount),
      danmakuCountText: formatCompactCount(danmakuCount),
      publishTimeText: formatYyyyMmDdFromUnixSeconds(created) ?? '时间未知',
      ownerMid: _readInt(json['mid']) ?? fallbackMid,
      ownerName: ownerName.isEmpty ? '未知UP主' : ownerName,
      description: _cleanText(json['description'] as String?),
    );
  }

  UpCollection _mapCollectionListItem(Map<String, dynamic> json) {
    final Map<String, dynamic> meta = _asNullableMap(json['meta']) ?? json;
    return _mapCollectionMeta(meta);
  }

  UpCollection _mapCollectionMeta(
    Map<String, dynamic> json, {
    int fallbackMid = 0,
  }) {
    final int updatedAt =
        _readInt(json['last_update_ts']) ?? _readInt(json['ptime']) ?? 0;
    return UpCollection(
      seasonId: _readInt(json['season_id']) ?? _readInt(json['id']) ?? 0,
      mid: _readInt(json['mid']) ?? fallbackMid,
      title: (json['name'] as String? ?? json['title'] as String? ?? '').trim(),
      coverUrl: normalizeHttpUrl(json['cover'] as String? ?? ''),
      total: _readInt(json['total']) ?? _readInt(json['ep_count']) ?? 0,
      description: _cleanText(json['description'] as String?),
      updatedAt: updatedAt > 0
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000)
          : null,
    );
  }

  UpCollectionItem _mapCollectionItem(Map<String, dynamic> json) {
    final int durationSeconds = _readInt(json['duration']) ?? 0;
    final int publishedAt =
        _readInt(json['pubdate']) ?? _readInt(json['ctime']) ?? 0;
    final Map<String, dynamic> stat =
        _asNullableMap(json['stat']) ?? <String, dynamic>{};
    final int playCount = _readInt(stat['view']) ?? _readInt(json['view']) ?? 0;

    return UpCollectionItem(
      aid: _readInt(json['aid']) ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: (json['title'] as String? ?? '').trim(),
      coverUrl: normalizeHttpUrl(json['pic'] as String? ?? ''),
      durationText: _formatDuration(durationSeconds),
      playCountText: formatCompactCount(playCount),
      publishTimeText: formatYyyyMmDdFromUnixSeconds(publishedAt) ?? '时间未知',
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliUpException('Unexpected UP response format.');
    }
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    return asNullableStringKeyedMap(value);
  }

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) {
      return '--:--';
    }
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String? _cleanText(String? value) {
    final String cleaned = (value ?? '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }
}
