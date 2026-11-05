import 'dart:convert';

import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:dio/dio.dart';
import 'package:meting_dart/meting_dart.dart';

typedef MusicChartPlaylistRequest =
    Future<Object?> Function(MetingServer server, String chartId);
typedef MusicChartCoverRequest =
    Future<String> Function(MetingServer server, String pictureId);

class MusicChartException implements Exception {
  const MusicChartException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MusicChartRepository {
  MusicChartRepository({
    Dio? dio,
    MusicChartPlaylistRequest? playlistRequest,
    MusicChartCoverRequest? coverRequest,
  }) : _dio = dio ?? Dio(),
       _playlistRequest = playlistRequest ?? _defaultPlaylistRequest,
       _coverRequest = coverRequest ?? _defaultCoverRequest;

  static const int maxTrackCount = 30;
  static const Duration cacheTtl = Duration(minutes: 10);
  static const String _kugouRankUrl =
      'https://mobiles.kugou.com/api/v3/rank/song';

  final Dio _dio;
  final MusicChartPlaylistRequest _playlistRequest;
  final MusicChartCoverRequest _coverRequest;
  final Map<MusicChartPlatform, _CachedChart> _cache =
      <MusicChartPlatform, _CachedChart>{};

  Future<List<MusicChartTrack>> fetchTracks(MusicChartPlatform platform) async {
    final _CachedChart? cached = _cache[platform];
    if (cached != null && !cached.isExpired) {
      return cached.tracks;
    }

    final List<MusicChartTrack> tracks = platform == MusicChartPlatform.kugou
        ? await _fetchKugou(platform)
        : await _fetchMeting(platform);
    _cache[platform] = _CachedChart(tracks: tracks, fetchedAt: DateTime.now());
    return tracks;
  }

  Future<List<MusicChartTrack>> _fetchMeting(
    MusicChartPlatform platform,
  ) async {
    final Object? response = await _playlistRequest(
      platform.server,
      platform.chartId,
    );
    final List<dynamic> rawItems = _decodeList(response);
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final dynamic rawItem in rawItems) {
      final Map<String, dynamic>? json = _asMap(rawItem);
      if (json == null) {
        continue;
      }
      final String title = _readString(json['name'] ?? json['title']);
      final String artist = _readArtist(json['artist'] ?? json['author']);
      if (title.isEmpty) {
        continue;
      }
      final String pictureId = _readString(json['pic_id']);
      String coverUrl = '';
      if (pictureId.isNotEmpty) {
        try {
          coverUrl = await _coverRequest(platform.server, pictureId);
        } on Object {
          coverUrl = '';
        }
      }
      tracks.add(
        MusicChartTrack(
          platform: platform,
          rank: 0,
          title: title,
          artist: artist,
          coverUrl: coverUrl,
          durationSeconds: _readDurationSeconds(json['duration']),
        ),
      );
    }

    return _finalizeTracks(tracks);
  }

  Future<List<MusicChartTrack>> _fetchKugou(MusicChartPlatform platform) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      _kugouRankUrl,
      queryParameters: <String, dynamic>{
        'rankid': platform.chartId,
        'page': 1,
        'pagesize': maxTrackCount,
        'plat': 2,
        'version': 8990,
      },
      options: Options(responseType: ResponseType.json),
    );
    return parseKugouRank(response.data, platform);
  }

  static List<MusicChartTrack> parseKugouRank(
    Object? payload,
    MusicChartPlatform platform,
  ) {
    final Object? decoded = payload is String ? _tryDecode(payload) : payload;
    final Map<String, dynamic>? root = _asMap(decoded);
    final Map<String, dynamic> data =
        _asMap(root?['data']) ?? <String, dynamic>{};
    final List<MusicChartTrack> tracks = <MusicChartTrack>[];
    for (final dynamic rawItem in asListOfMaps(data['info'])) {
      final Map<String, dynamic> json = rawItem;
      final String rawName = _readString(json['songname']);
      String artist = '';
      final List<Map<String, dynamic>> authors = asListOfMaps(json['authors']);
      if (authors.isNotEmpty) {
        artist = authors
            .map(
              (Map<String, dynamic> author) =>
                  _readString(author['author_name']),
            )
            .where((String value) => value.isNotEmpty)
            .join(' / ');
      }
      if (artist.isEmpty) {
        final String filename = _readString(json['filename']);
        final int splitIndex = filename.indexOf(' - ');
        if (splitIndex > 0) {
          artist = filename.substring(0, splitIndex).trim();
        }
      }
      if (rawName.isEmpty) {
        continue;
      }
      tracks.add(
        MusicChartTrack(
          platform: platform,
          rank: 0,
          title: rawName,
          artist: artist,
          coverUrl: _kugouCoverUrl(json),
          durationSeconds: _readKugouDuration(json['duration']),
        ),
      );
    }
    return _finalizeTracks(tracks);
  }

  static String _kugouCoverUrl(Map<String, dynamic> json) {
    final Map<String, dynamic>? params = _asMap(json['trans_param']);
    final String raw = _readString(params?['union_cover']).isNotEmpty
        ? _readString(params?['union_cover'])
        : _readString(json['album_sizable_cover']);
    return raw.isEmpty ? '' : raw.replaceAll('{size}', '300');
  }

  static int _readKugouDuration(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  static List<MusicChartTrack> _finalizeTracks(List<MusicChartTrack> tracks) {
    final List<MusicChartTrack> unique = <MusicChartTrack>[];
    final Set<String> seen = <String>{};
    for (final MusicChartTrack track in tracks) {
      final String uniqueKey =
          '${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
      if (!seen.add(uniqueKey)) {
        continue;
      }
      unique.add(track);
      if (unique.length >= maxTrackCount) {
        break;
      }
    }
    return List<MusicChartTrack>.unmodifiable(<MusicChartTrack>[
      for (int index = 0; index < unique.length; index += 1)
        unique[index].copyWith(rank: index + 1),
    ]);
  }

  static Future<Object?> _defaultPlaylistRequest(
    MetingServer server,
    String chartId,
  ) {
    final Meting meting = Meting(server: server.apiValue)..format(true);
    return meting.playlist(chartId);
  }

  static Future<String> _defaultCoverRequest(
    MetingServer server,
    String pictureId,
  ) {
    final Meting meting = Meting(server: server.apiValue)..format(false);
    return meting.pic(pictureId, size: 300);
  }

  static Object? _tryDecode(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  static List<dynamic> _decodeList(Object? response) {
    final Object? decoded = response is String
        ? _tryDecode(response)
        : response;
    return decoded is List ? decoded : const <dynamic>[];
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    return asNullableStringKeyedMap(value);
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String _readArtist(Object? value) {
    if (value is List) {
      return value
          .where((Object? item) => item != null)
          .map((Object? item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .join(' / ');
    }
    return _readString(value);
  }

  static int _readDurationSeconds(Object? value) {
    final int raw = value is num
        ? value.toInt()
        : int.tryParse(_readString(value)) ?? 0;
    if (raw <= 0) {
      return 0;
    }
    if (raw >= 10000) {
      return (raw / 1000).round();
    }
    return raw;
  }
}

class _CachedChart {
  const _CachedChart({required this.tracks, required this.fetchedAt});

  final List<MusicChartTrack> tracks;
  final DateTime fetchedAt;

  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > MusicChartRepository.cacheTtl;
}
