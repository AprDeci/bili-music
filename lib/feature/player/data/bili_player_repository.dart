import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

class BiliPlayerRepository {
  const BiliPlayerRepository(this._apiClient);

  final BiliApiClient _apiClient;

  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
  }) async {
    if (!item.hasIdentity) {
      throw const BiliPlayerException('Missing video identity for playback.');
    }

    final _VideoViewInfo viewInfo = await _fetchVideoView(item);
    final _VideoPageInfo pageInfo = viewInfo.resolvePage(item);

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

    return PlayerLoadResult(
      item: viewInfo.enrich(item, pageInfo),
      availableParts: viewInfo.buildPlayableItems(item),
      audioStream: AudioStreamInfo(
        streamUrl: streamUrl,
        backupUrls: backupUrls,
        headers: _buildPlaybackHeaders(session),
        cid: pageInfo.cid,
        duration: durationSeconds > 0
            ? Duration(seconds: durationSeconds)
            : null,
        pageTitle: pageInfo.part,
        qualityLabel: _buildQualityLabel(selected),
      ),
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

    final Map<String, dynamic> stat = _asMapOrEmpty(data['stat']);

    return _VideoViewInfo(
      pages: pages,
      title: data['title'] as String? ?? item.title,
      author: _readOwnerName(data['owner']) ?? item.author,
      description: _readDescription(data) ?? item.description,
      playCountText:
          _formatCount((stat['view'] as num? ?? 0).toInt()) ??
          item.playCountText,
      danmakuCountText:
          _formatCount((stat['danmaku'] as num? ?? 0).toInt()) ??
          item.danmakuCountText,
      likeCountText:
          _formatCount((stat['like'] as num? ?? 0).toInt()) ??
          item.likeCountText,
      coinCountText:
          _formatCount((stat['coin'] as num? ?? 0).toInt()) ??
          item.coinCountText,
      favoriteCountText:
          _formatCount((stat['favorite'] as num? ?? 0).toInt()) ??
          item.favoriteCountText,
      shareCountText:
          _formatCount((stat['share'] as num? ?? 0).toInt()) ??
          item.shareCountText,
      replyCountText:
          _formatCount((stat['reply'] as num? ?? 0).toInt()) ??
          item.replyCountText,
      publishTimeText:
          _formatPublishTime(
            (data['pubdate'] as num? ?? data['ctime'] as num? ?? 0).toInt(),
          ) ??
          item.publishTimeText,
    );
  }

  _VideoPageInfo _mapPageInfo(Map<String, dynamic> json) {
    return _VideoPageInfo(
      cid: (json['cid'] as num? ?? 0).toInt(),
      page: (json['page'] as num? ?? 1).toInt(),
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

  Map<String, dynamic> _asMapOrEmpty(dynamic value) {
    if (value == null) {
      return <String, dynamic>{};
    }
    return _asMap(value);
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

  String? _readOwnerName(dynamic value) {
    final Map<String, dynamic> owner = _asMapOrEmpty(value);
    final String name = owner['name'] as String? ?? '';
    return name.isEmpty ? null : name;
  }

  String? _readDescription(Map<String, dynamic> data) {
    final String description =
        data['desc'] as String? ?? data['description'] as String? ?? '';
    final String trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _formatPublishTime(int timestamp) {
    if (timestamp <= 0) {
      return null;
    }

    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    );
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String? _formatCount(int value) {
    if (value <= 0) {
      return null;
    }
    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(1)}亿';
    }
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万';
    }
    return value.toString();
  }
}

class PlayerLoadResult {
  const PlayerLoadResult({
    required this.item,
    required this.availableParts,
    required this.audioStream,
  });

  final PlayableItem item;
  final List<PlayableItem> availableParts;
  final AudioStreamInfo audioStream;
}

class BiliPlayerException implements Exception {
  const BiliPlayerException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _VideoViewInfo {
  const _VideoViewInfo({
    required this.pages,
    required this.title,
    required this.author,
    this.description,
    this.playCountText,
    this.danmakuCountText,
    this.likeCountText,
    this.coinCountText,
    this.favoriteCountText,
    this.shareCountText,
    this.replyCountText,
    this.publishTimeText,
  });

  final List<_VideoPageInfo> pages;
  final String title;
  final String author;
  final String? description;
  final String? playCountText;
  final String? danmakuCountText;
  final String? likeCountText;
  final String? coinCountText;
  final String? favoriteCountText;
  final String? shareCountText;
  final String? replyCountText;
  final String? publishTimeText;

  _VideoPageInfo resolvePage(PlayableItem item) {
    final int? targetCid = item.cid;
    if (targetCid != null && targetCid > 0) {
      for (final _VideoPageInfo page in pages) {
        if (page.cid == targetCid) {
          return page;
        }
      }
    }

    final int? targetPage = item.page;
    if (targetPage != null && targetPage > 0 && targetPage <= pages.length) {
      return pages[targetPage - 1];
    }

    return pages.first;
  }

  List<PlayableItem> buildPlayableItems(PlayableItem item) {
    return pages
        .map((_VideoPageInfo pageInfo) {
          return enrich(item, pageInfo);
        })
        .toList(growable: false);
  }

  PlayableItem enrich(PlayableItem item, _VideoPageInfo pageInfo) {
    return item.copyWith(
      title: title,
      author: author,
      cid: pageInfo.cid,
      page: pageInfo.page,
      pageTitle: pageInfo.part,
      description: description,
      playCountText: playCountText,
      danmakuCountText: danmakuCountText,
      likeCountText: likeCountText,
      coinCountText: coinCountText,
      favoriteCountText: favoriteCountText,
      shareCountText: shareCountText,
      replyCountText: replyCountText,
      publishTimeText: publishTimeText,
    );
  }
}

class _VideoPageInfo {
  const _VideoPageInfo({
    required this.cid,
    required this.page,
    required this.part,
  });

  final int cid;
  final int page;
  final String part;
}
