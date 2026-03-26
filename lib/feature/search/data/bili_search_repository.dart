import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class BiliSearchRepository {
  const BiliSearchRepository(this._apiClient);

  final BiliApiClient _apiClient;

  Future<List<SearchResultItem>> searchVideos(String keyword) async {
    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/web-interface/wbi/search/type',
      queryParameters: <String, dynamic>{
        'search_type': 'video',
        'keyword': keyword,
        'page': 1,
      },
      requiresWbi: true,
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final List<dynamic> rawResults =
        data['result'] as List<dynamic>? ?? <dynamic>[];

    return rawResults
        .whereType<Map>()
        .map(
          (Map rawItem) => _mapVideoItem(
            rawItem.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  SearchResultItem _mapVideoItem(Map<String, dynamic> json) {
    final int aid = (json['aid'] as num? ?? json['id'] as num? ?? 0).toInt();
    final int playCount = (json['play'] as num? ?? 0).toInt();
    final int danmakuCount = (json['video_review'] as num? ?? 0).toInt();
    final int publishTimestamp = (json['pubdate'] as num? ?? 0).toInt();

    return SearchResultItem(
      aid: aid,
      bvid: json['bvid'] as String? ?? '',
      title: _stripKeywordTag(json['title'] as String? ?? ''),
      author: json['author'] as String? ?? '未知UP主',
      coverUrl: _normalizeCoverUrl(json['pic'] as String? ?? ''),
      duration: json['duration'] as String? ?? '--:--',
      playCountText: _formatCount(playCount),
      danmakuCountText: _formatCount(danmakuCount),
      publishTimeText: _formatPublishTime(publishTimestamp),
      tagText: json['typename'] as String? ?? '视频',
      description: _cleanDescription(json['description'] as String?),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    throw const BiliSearchException('Unexpected search response format.');
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

  String _normalizeCoverUrl(String value) {
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }
    return 'https://$value';
  }

  String _formatCount(int value) {
    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(1)}亿';
    }
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万';
    }
    return value.toString();
  }

  String _formatPublishTime(int timestamp) {
    if (timestamp <= 0) {
      return '时间未知';
    }
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    );
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class BiliSearchException implements Exception {
  const BiliSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}
