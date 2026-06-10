import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/common/util/url_util.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:dio/dio.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/domain/search_user_page_result.dart';

class BiliSearchRepository {
  const BiliSearchRepository(this._client);

  static const int _defaultPageSize = 20;
  static const String _suggestEndpoint =
      'https://s.search.bilibili.com/main/suggest';

  final BiliHttpClient _client;

  Future<SearchPageResult> searchVideos(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    return _searchVideos(
      keyword,
      page: page,
      sort: sort,
      mode: BiliRequestMode.defaultCookie,
    );
  }

  Future<SearchPageResult> searchVideosAnonymously(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    return _searchVideos(
      keyword,
      page: page,
      sort: sort,
      mode: BiliRequestMode.anonymous,
    );
  }

  Future<SearchUserPageResult> searchUsers(
    String keyword, {
    int page = 1,
  }) async {
    return _searchUsers(
      keyword,
      page: page,
      mode: BiliRequestMode.defaultCookie,
    );
  }

  Future<SearchPageResult> _searchVideos(
    String keyword, {
    required int page,
    required SearchSort sort,
    required BiliRequestMode mode,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/web-interface/wbi/search/type',
      queryParameters: <String, dynamic>{
        'search_type': SearchType.video.apiValue,
        'keyword': keyword,
        'order': sort.apiValue,
        'page': page,
      },
      requiresWbi: true,
      mode: mode,
    );

    final Map<String, dynamic> data = asStringKeyedMap(json['data']);
    final List<dynamic> rawResults =
        data['result'] as List<dynamic>? ?? <dynamic>[];
    final List<SearchResultItem> items = rawResults
        .whereType<Map>()
        .map(
          (Map rawItem) => _mapVideoItem(
            rawItem.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
    final int resolvedPage = _readPositiveInt(data['page']) ?? page;
    final int? totalPages = _readTotalPages(data);
    final int pageSize = _readPositiveInt(data['pagesize']) ?? _defaultPageSize;

    return SearchPageResult(
      items: items,
      page: resolvedPage,
      totalPages: totalPages,
      hasMore: _hasMoreItems(
        currentPage: resolvedPage,
        totalPages: totalPages,
        itemCount: items.length,
        pageSize: pageSize,
      ),
    );
  }

  Future<SearchUserPageResult> _searchUsers(
    String keyword, {
    required int page,
    required BiliRequestMode mode,
  }) async {
    final Map<String, dynamic> json = await _client.getJson(
      '/x/web-interface/wbi/search/type',
      queryParameters: <String, dynamic>{
        'search_type': SearchType.up.apiValue,
        'keyword': keyword,
        'page': page,
        'user_type': 0,
      },
      requiresWbi: true,
      mode: mode,
    );

    final Map<String, dynamic> data = asStringKeyedMap(json['data']);
    final List<dynamic> rawResults =
        data['result'] as List<dynamic>? ?? <dynamic>[];
    final List<SearchUserItem> items = rawResults
        .whereType<Map>()
        .map(
          (Map rawItem) => _mapUserItem(
            rawItem.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .where((SearchUserItem item) => item.mid > 0)
        .toList();
    final int resolvedPage = _readPositiveInt(data['page']) ?? page;
    final int? totalPages = _readTotalPages(data);
    final int pageSize = _readPositiveInt(data['pagesize']) ?? _defaultPageSize;

    return SearchUserPageResult(
      items: items,
      page: resolvedPage,
      totalPages: totalPages,
      hasMore: _hasMoreItems(
        currentPage: resolvedPage,
        totalPages: totalPages,
        itemCount: items.length,
        pageSize: pageSize,
      ),
    );
  }

  Future<List<String>> fetchSuggestions(String term) async {
    final Response<dynamic> response = await _client.get<dynamic>(
      _suggestEndpoint,
      queryParameters: <String, dynamic>{'term': term},
    );
    final Map<String, dynamic> json = _asMap(response.data);
    final Map<String, dynamic>? result = _asNullableMap(json['result']);
    final List<dynamic> rawTags =
        result?['tag'] as List<dynamic>? ?? <dynamic>[];

    final Set<String> seen = <String>{};
    final List<String> suggestions = <String>[];
    for (final dynamic rawTag in rawTags) {
      final Map<String, dynamic>? tag = _asNullableMap(rawTag);
      final String value = (tag?['value'] as String? ?? '').trim();
      if (value.isEmpty || !seen.add(value)) {
        continue;
      }
      suggestions.add(value);
      if (suggestions.length >= 10) {
        break;
      }
    }

    return suggestions;
  }

  SearchResultItem _mapVideoItem(Map<String, dynamic> json) {
    final int aid = (json['aid'] as num? ?? json['id'] as num? ?? 0).toInt();
    final int playCount = (json['play'] as num? ?? 0).toInt();
    final int danmakuCount = (json['video_review'] as num? ?? 0).toInt();
    final int publishTimestamp = (json['pubdate'] as num? ?? 0).toInt();

    return SearchResultItem(
      aid: aid,
      bvid: json['bvid'] as String? ?? '',
      typeId: _readInt(json['typeid']) ?? 0,
      title: _stripKeywordTag(json['title'] as String? ?? ''),
      author: json['author'] as String? ?? '未知UP主',
      coverUrl: normalizeHttpUrl(json['pic'] as String? ?? ''),
      duration: json['duration'] as String? ?? '--:--',
      playCountText: formatCompactCount(playCount),
      danmakuCountText: formatCompactCount(danmakuCount),
      publishTimeText:
          formatYyyyMmDdFromUnixSeconds(publishTimestamp) ?? '时间未知',
      tagText: json['typename'] as String? ?? '视频',
      description: _cleanDescription(json['description'] as String?),
    );
  }

  SearchUserItem _mapUserItem(Map<String, dynamic> json) {
    final int fans = (json['fans'] as num? ?? 0).toInt();
    final int videos = (json['videos'] as num? ?? 0).toInt();
    final Map<String, dynamic>? officialVerify = _asNullableMap(
      json['official_verify'],
    );

    return SearchUserItem(
      mid: _readInt(json['mid']) ?? 0,
      name: _stripKeywordTag(json['uname'] as String? ?? '未知UP主'),
      avatarUrl: normalizeHttpUrl(json['upic'] as String? ?? ''),
      sign: _cleanDescription(json['usign'] as String?) ?? '',
      fansText: formatCompactCount(fans),
      videoCountText: formatCompactCount(videos),
      level: _readInt(json['level']) ?? 0,
      officialType: _readInt(officialVerify?['type']),
      officialTitle: _cleanDescription(officialVerify?['desc'] as String?),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliSearchException('Unexpected search response format.');
    }
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    return asNullableStringKeyedMap(value);
  }

  int? _readTotalPages(Map<String, dynamic> data) {
    final Map<String, dynamic>? pageInfo = asNullableStringKeyedMap(
      data['pageinfo'],
    );

    return _readPositiveInt(data['numPages']) ??
        _readPositiveInt(data['num_pages']) ??
        _readPositiveInt(pageInfo?['numPages']) ??
        _readPositiveInt(pageInfo?['num_pages']) ??
        _readPositiveInt(pageInfo?['pages']);
  }

  int? _readPositiveInt(dynamic value) {
    if (value is num) {
      final int intValue = value.toInt();
      return intValue > 0 ? intValue : null;
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return null;
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

  bool _hasMoreItems({
    required int currentPage,
    required int? totalPages,
    required int itemCount,
    required int pageSize,
  }) {
    if (totalPages != null) {
      return currentPage < totalPages;
    }

    return itemCount >= pageSize && itemCount > 0;
  }

  String _stripKeywordTag(String value) {
    return value
        .replaceAll(RegExp(r'<em\s+class="keyword">', caseSensitive: false), '')
        .replaceAll('</em>', '')
        .trim();
  }

  String? _cleanDescription(String? value) {
    if (value == null) {
      return null;
    }
    final String cleaned = value
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }
}

class BiliSearchException implements Exception {
  const BiliSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}
