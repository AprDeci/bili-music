import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:dio/dio.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BiliPlayerRepository> biliPlayerRepositoryProvider =
    Provider<BiliPlayerRepository>((Ref ref) {
      return BiliPlayerRepository(ref.read(biliApiClientProvider));
    });

class BiliPlayerRepository {
  const BiliPlayerRepository(this._apiClient);

  final BiliApiClient _apiClient;

  Future<PlayerOnlineAudience> fetchOnlineAudience({
    required int cid,
    required int aid,
    required String bvid,
  }) async {
    if (cid <= 0) {
      throw const BiliPlayerException(
        'Missing cid for online audience request.',
      );
    }
    if (aid <= 0 && bvid.isEmpty) {
      throw const BiliPlayerException(
        'Missing video identity for online audience request.',
      );
    }

    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/player/online/total',
      queryParameters: <String, dynamic>{
        if (aid > 0) 'aid': aid,
        if (aid <= 0 && bvid.isNotEmpty) 'bvid': bvid,
        'cid': cid,
      },
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> showSwitch = _asMapOrEmpty(data['show_switch']);
    final String? totalText = _readNonEmptyString(data['total']);
    final String? countText = _readNonEmptyString(data['count']);

    return PlayerOnlineAudience(
      totalText: totalText,
      countText: countText,
      showTotal: showSwitch['total'] as bool? ?? totalText != null,
      showCount: showSwitch['count'] as bool? ?? countText != null,
      fetchedAt: DateTime.now(),
    );
  }

  Future<PlayableItem> resolvePreferredPart(
    PlayableItem item, {
    int preferredPage = 1,
  }) async {
    if (!item.hasIdentity) {
      throw const BiliPlayerException('Missing video identity for playback.');
    }

    final _VideoViewInfo viewInfo = await _fetchVideoView(item);
    final PlayableItem preferredItem = item.copyWith(page: preferredPage);
    final _VideoPageInfo pageInfo = viewInfo.resolvePage(preferredItem);
    return viewInfo.enrich(item, pageInfo);
  }

  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
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
        'fnval': 4048,
        'fnver': 0,
        'qn': 80,
        'fourk': 1,
      },
      requiresWbi: true,
      options: Options(headers: _buildPlayurlRequestHeaders(session)),
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> dash = _asMap(data['dash']);
    final Map<String, dynamic> flac = _asMapOrEmpty(dash['flac']);
    final Map<String, dynamic> dolby = _asMapOrEmpty(dash['dolby']);
    final List<_AudioStreamCandidate> audioCandidates = <_AudioStreamCandidate>[
      ..._asListOfMaps(
        dash['audio'],
      ).map(_mapAudioStreamCandidate).whereType<_AudioStreamCandidate>(),
      ..._readFlacAudioCandidate(flac),
    ];
    if (audioCandidates.isEmpty) {
      throw const BiliPlayerException(
        'No audio stream available for this video.',
      );
    }

    audioCandidates.sort(
      (_AudioStreamCandidate left, _AudioStreamCandidate right) =>
          right.bandwidth.compareTo(left.bandwidth),
    );

    final _AudioStreamCandidate selected = _selectAudioCandidate(
      audioCandidates,
      qualityPreference: qualityPreference,
      preferredQualityId: preferredQualityId,
    );
    final List<AudioQualityOption> availableQualities = audioCandidates
        .map(
          (_AudioStreamCandidate candidate) => AudioQualityOption(
            qualityId: candidate.qualityId,
            bandwidth: candidate.bandwidth,
            label:
                candidate.qualityLabel ?? _buildFallbackQualityLabel(candidate),
            isSelected:
                candidate.qualityId == selected.qualityId &&
                candidate.bandwidth == selected.bandwidth &&
                candidate.streamUrl == selected.streamUrl,
          ),
        )
        .toList(growable: false);

    final int durationSeconds =
        (data['timelength'] as num? ?? 0).toInt() ~/ 1000;

    return PlayerLoadResult(
      item: viewInfo.enrich(item, pageInfo),
      availableParts: viewInfo.buildPlayableItems(item),
      audioStream: AudioStreamInfo(
        streamUrl: selected.streamUrl,
        backupUrls: selected.backupUrls,
        headers: _buildPlaybackHeaders(session),
        cid: pageInfo.cid,
        duration: durationSeconds > 0
            ? Duration(seconds: durationSeconds)
            : null,
        bandwidth: selected.bandwidth,
        availableQualities: availableQualities,
        pageTitle: pageInfo.part,
        qualityId: selected.qualityId,
        qualityLabel: selected.qualityLabel,
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

    final int replyCount = (stat['reply'] as num? ?? 0).toInt();

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
      replyCount: replyCount > 0 ? replyCount : item.replyCount,
      replyCountText: _formatCount(replyCount) ?? item.replyCountText,
      publishTimeText:
          formatYyyyMmDdFromUnixSeconds(
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
      if (userAgent case final String userAgent) 'User-Agent': userAgent,
      if (referer case final String referer) 'Referer': referer,
      if (origin case final String origin) 'Origin': origin,
      if (session != null && session.cookie.isNotEmpty)
        'Cookie': session.cookie,
    };
  }

  Map<String, String> _buildPlayurlRequestHeaders(BiliSession? session) {
    if (session == null || session.cookie.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Cookie': session.cookie};
  }

  _AudioStreamCandidate? _mapAudioStreamCandidate(Map<String, dynamic> json) {
    final String streamUrl =
        json['baseUrl'] as String? ?? json['base_url'] as String? ?? '';
    if (streamUrl.isEmpty) {
      return null;
    }

    final int qualityId = (json['id'] as num? ?? 0).toInt();
    final int bandwidth = (json['bandwidth'] as num? ?? 0).toInt();
    final List<String> backupUrls = <String>[
      ..._asStringList(json['backupUrl']),
      ..._asStringList(json['backup_url']),
    ];

    return _AudioStreamCandidate(
      qualityId: qualityId > 0 ? qualityId : null,
      bandwidth: bandwidth,
      streamUrl: streamUrl,
      backupUrls: backupUrls,
      qualityLabel: _buildQualityLabel(
        qualityId: qualityId > 0 ? qualityId : null,
        bandwidth: bandwidth,
      ),
    );
  }

  Iterable<_AudioStreamCandidate> _readFlacAudioCandidate(
    Map<String, dynamic> flac,
  ) sync* {
    if (flac.isEmpty) {
      return;
    }

    final Map<String, dynamic> flacAudio = _asMapOrEmpty(flac['audio']);
    if (flacAudio.isEmpty) {
      return;
    }

    final _AudioStreamCandidate? candidate = _mapAudioStreamCandidate(
      flacAudio,
    );
    if (candidate != null) {
      yield candidate;
    }
  }

  _AudioStreamCandidate _selectAudioCandidate(
    List<_AudioStreamCandidate> candidates, {
    required PlayerAudioQualityPreference qualityPreference,
    required int? preferredQualityId,
  }) {
    if (preferredQualityId != null) {
      for (final _AudioStreamCandidate candidate in candidates) {
        if (candidate.qualityId == preferredQualityId) {
          return candidate;
        }
      }
    }

    final int? preferredQualityFromSetting = switch (qualityPreference) {
      PlayerAudioQualityPreference.auto => null,
      PlayerAudioQualityPreference.hires => 30251,
      PlayerAudioQualityPreference.k192 => 30280,
      PlayerAudioQualityPreference.k132 => 30232,
    };
    if (preferredQualityFromSetting == null) {
      return candidates.first;
    }

    for (final _AudioStreamCandidate candidate in candidates) {
      if (candidate.qualityId == preferredQualityFromSetting) {
        return candidate;
      }
    }
    return candidates.first;
  }

  String _buildFallbackQualityLabel(_AudioStreamCandidate candidate) {
    return candidate.qualityLabel ??
        '${(candidate.bandwidth / 1000).round()} kbps';
  }

  String? _buildQualityLabel({
    required int? qualityId,
    required int bandwidth,
  }) {
    switch (qualityId) {
      case 30251:
        return 'Hi-Res';
      case 30280:
        return '192K';
      case 30232:
        return '132K';
      case 30216:
        return '64K';
      case 30250:
        return '杜比';
    }
    if (bandwidth <= 0) {
      return null;
    }
    final double kbps = bandwidth / 1000;
    return '${kbps.toStringAsFixed(0)} kbps';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliPlayerException('Unexpected player response format.');
    }
  }

  Map<String, dynamic> _asMapOrEmpty(dynamic value) {
    return asStringKeyedMapOrEmpty(value);
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    return asListOfMaps(value);
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

  String? _formatCount(int value) {
    if (value <= 0) {
      return null;
    }
    return formatCompactCount(value);
  }

  String? _readNonEmptyString(dynamic value) {
    final String text = value as String? ?? '';
    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
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

class _AudioStreamCandidate {
  const _AudioStreamCandidate({
    required this.qualityId,
    required this.bandwidth,
    required this.streamUrl,
    required this.backupUrls,
    required this.qualityLabel,
  });

  final int? qualityId;
  final int bandwidth;
  final String streamUrl;
  final List<String> backupUrls;
  final String? qualityLabel;
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
    this.replyCount,
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
  final int? replyCount;
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
      replyCount: replyCount,
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
