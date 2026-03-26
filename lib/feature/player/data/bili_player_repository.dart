import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

class BiliPlayerRepository {
  const BiliPlayerRepository(this._apiClient);

  final BiliApiClient _apiClient;

  Future<AudioStreamInfo> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
  }) async {
    if (!item.hasIdentity) {
      throw const BiliPlayerException('Missing video identity for playback.');
    }

    final _VideoViewInfo viewInfo = await _fetchVideoView(item);
    final _VideoPageInfo pageInfo = viewInfo.pages.first;

    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/player/wbi/playurl',
      queryParameters: <String, dynamic>{
        if (item.bvid.isNotEmpty) 'bvid': item.bvid,
        if (item.aid > 0) 'avid': item.aid,
        'cid': pageInfo.cid,
        'fnval': 16,
        'qn': 80,
        'fourk': 1,
      },
      requiresWbi: true,
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> dash = _asMap(data['dash']);
    final List<Map<String, dynamic>> audioList = _asListOfMaps(dash['audio']);
    if (audioList.isEmpty) {
      throw const BiliPlayerException(
        'No audio stream available for this video.',
      );
    }

    audioList.sort((Map<String, dynamic> left, Map<String, dynamic> right) {
      final int leftBandwidth = (left['bandwidth'] as num? ?? 0).toInt();
      final int rightBandwidth = (right['bandwidth'] as num? ?? 0).toInt();
      return rightBandwidth.compareTo(leftBandwidth);
    });

    final Map<String, dynamic> selected = audioList.first;
    final String streamUrl =
        selected['baseUrl'] as String? ?? selected['base_url'] as String? ?? '';
    if (streamUrl.isEmpty) {
      throw const BiliPlayerException('Audio stream URL is missing.');
    }

    final List<String> backupUrls = <String>[
      ..._asStringList(selected['backupUrl']),
      ..._asStringList(selected['backup_url']),
    ];

    final int durationSeconds =
        (data['timelength'] as num? ?? 0).toInt() ~/ 1000;

    return AudioStreamInfo(
      streamUrl: streamUrl,
      backupUrls: backupUrls,
      headers: _buildPlaybackHeaders(session),
      cid: pageInfo.cid,
      duration: durationSeconds > 0 ? Duration(seconds: durationSeconds) : null,
      pageTitle: pageInfo.part,
      qualityLabel: _buildQualityLabel(selected),
    );
  }

  Future<_VideoViewInfo> _fetchVideoView(PlayableItem item) async {
    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/web-interface/view',
      queryParameters: <String, dynamic>{
        if (item.bvid.isNotEmpty) 'bvid': item.bvid,
        if (item.aid > 0) 'aid': item.aid,
      },
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final List<_VideoPageInfo> pages = _asListOfMaps(
      data['pages'],
    ).map(_mapPageInfo).toList();

    if (pages.isEmpty) {
      throw const BiliPlayerException('No playable page found for this video.');
    }

    return _VideoViewInfo(pages: pages);
  }

  _VideoPageInfo _mapPageInfo(Map<String, dynamic> json) {
    return _VideoPageInfo(
      cid: (json['cid'] as num? ?? 0).toInt(),
      part: json['part'] as String? ?? 'P1',
    );
  }

  Map<String, String> _buildPlaybackHeaders(BiliSession? session) {
    final String? userAgent = NetConfig.defaultHeaders['User-Agent'] as String?;
    final String? referer = NetConfig.defaultHeaders['Referer'] as String?;
    final String? origin = NetConfig.defaultHeaders['Origin'] as String?;

    return <String, String>{
      if (userAgent != null) 'User-Agent': userAgent,
      if (referer != null) 'Referer': referer,
      if (origin != null) 'Origin': origin,
      if (session != null && session.cookie.isNotEmpty)
        'Cookie': session.cookie,
    };
  }

  String? _buildQualityLabel(Map<String, dynamic> json) {
    final int bandwidth = (json['bandwidth'] as num? ?? 0).toInt();
    if (bandwidth <= 0) {
      return null;
    }
    final double kbps = bandwidth / 1000;
    return '${kbps.toStringAsFixed(0)} kbps';
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
    throw const BiliPlayerException('Unexpected player response format.');
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    final List<dynamic> list = value as List<dynamic>? ?? <dynamic>[];
    return list.whereType<Map>().map((Map item) {
      return item.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }).toList();
  }

  List<String> _asStringList(dynamic value) {
    final List<dynamic> list = value as List<dynamic>? ?? <dynamic>[];
    return list
        .whereType<String>()
        .where((String item) => item.isNotEmpty)
        .toList();
  }
}

class BiliPlayerException implements Exception {
  const BiliPlayerException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _VideoViewInfo {
  const _VideoViewInfo({required this.pages});

  final List<_VideoPageInfo> pages;
}

class _VideoPageInfo {
  const _VideoPageInfo({required this.cid, required this.part});

  final int cid;
  final String part;
}
