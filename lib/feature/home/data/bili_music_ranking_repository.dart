import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:dio/dio.dart';

class BiliMusicRankingRepository {
  const BiliMusicRankingRepository(this._apiClient);

  final BiliApiClient _apiClient;

  Future<List<MusicRankingItem>> fetchMusicRanking({
    bool requiresWbi = false,
  }) async {
    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/web-interface/ranking/v2?dm_img_list=[{"x":748,"y":-1686,"z":0,"timestamp":716,"k":123,"type":0}]&dm_img_str=V2ViR0wgMS&dm_cover_img_str=QU5HTEUgKE5WSURJQSwgTlZJRElBIEdlRm9yY2UgR1RYIDk4MCBEaXJlY3QzRDExIHZzXzVfMCBwc181XzApLCBvciBzaW1pbGFyR29vZ2xlIEluYy4gKE5WSURJQS&dm_img_inter={"ds":[{"t":0,"c":"","p":[9,3,3],"s":[80,6232,2116]}],"wh":[4904,4883,48],"of":[212,424,212]}',
      queryParameters: <String, dynamic>{'rid': 1003, 'type': 'all'},
      requiresWbi: requiresWbi,
      options: Options(
        headers: {
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0',
        },
      ),
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final List<dynamic> rawList = data['list'] as List<dynamic>? ?? <dynamic>[];

    return rawList
        .whereType<Map>()
        .map((Map rawItem) {
          final Map<String, dynamic> item = rawItem.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          );
          return _mapRankingItem(item);
        })
        .toList(growable: false);
  }

  MusicRankingItem _mapRankingItem(Map<String, dynamic> json) {
    final Map<String, dynamic>? owner = _asNullableMap(json['owner']);
    final Map<String, dynamic>? stat = _asNullableMap(json['stat']);
    final int durationSeconds = (json['duration'] as num? ?? 0).toInt();
    final int playCount = (stat?['view'] as num? ?? 0).toInt();

    return MusicRankingItem(
      aid: (json['aid'] as num? ?? 0).toInt(),
      bvid: json['bvid'] as String? ?? '',
      title: (json['title'] as String? ?? '').trim(),
      coverUrl: _normalizeCoverUrl(json['pic'] as String? ?? ''),
      author: (owner?['name'] as String? ?? '未知UP主').trim(),
      tagText: (json['tname'] as String? ?? '音乐').trim().isEmpty
          ? '音乐'
          : (json['tname'] as String? ?? '音乐').trim(),
      playCountText: _formatCount(playCount),
      durationText: _formatDuration(durationSeconds),
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
    throw const BiliMusicRankingException(
      'Unexpected ranking response format.',
    );
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return null;
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
      return '${(value / 100000000).toStringAsFixed(1)}亿播放';
    }
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万播放';
    }
    return '$value播放';
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '--:--';
    }
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class BiliMusicRankingException implements Exception {
  const BiliMusicRankingException(this.message);

  final String message;

  @override
  String toString() => message;
}
