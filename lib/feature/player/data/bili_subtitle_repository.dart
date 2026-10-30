import 'dart:convert';

import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';

class BiliSubtitleRepository {
  const BiliSubtitleRepository(this._client);

  final BiliHttpClient _client;

  Future<List<BiliSubtitleTrack>> fetchTracks(PlayableItem item) async {
    final BiliSession? session = _client.currentSession;
    final int? cid = item.cid;
    if (session == null || !session.isLoggedIn || cid == null || cid <= 0) {
      return const <BiliSubtitleTrack>[];
    }
    if (!item.hasIdentity) {
      throw const BiliSubtitleException(
        'Missing video identity for subtitles.',
      );
    }

    final Map<String, dynamic> json = await _client.getJson(
      '/x/player/wbi/v2',
      queryParameters: <String, dynamic>{
        if (item.bvid.isNotEmpty) 'bvid': item.bvid else 'aid': item.aid,
        'cid': cid,
      },
      requiresAuth: true,
      requiresWbi: session.hasWbiKeys,
    );
    if (json['code'] != 0) {
      throw BiliSubtitleException(
        'Subtitle API request failed.',
        code: json['code'] is int ? json['code'] as int : null,
      );
    }
    final Map<String, dynamic> data = _asMap(json['data']);
    if ((data.containsKey('cid') && data['cid'] != cid) ||
        (data.containsKey('bvid') &&
            item.bvid.isNotEmpty &&
            data['bvid'] != item.bvid) ||
        (data.containsKey('aid') && item.aid > 0 && data['aid'] != item.aid)) {
      throw const BiliSubtitleException('Subtitle video identity mismatch.');
    }
    if (data['need_login_subtitle'] == true ||
        (data.containsKey('login_mid') &&
            (data['login_mid'] is! num || data['login_mid'] <= 0))) {
      throw const BiliSubtitleException('Login is required for subtitles.');
    }
    if (data['subtitle'] == null) {
      throw const BiliSubtitleException('Subtitle metadata is missing.');
    }
    final Object? subtitles = _asMap(data['subtitle'])['subtitles'];
    if (subtitles is! List) {
      throw const BiliSubtitleException('Invalid subtitle track list.');
    }
    final List<BiliSubtitleTrack> tracks = <BiliSubtitleTrack>[];
    for (final Object? value in subtitles) {
      final Map<String, dynamic> subtitle = _asMap(value);
      if (subtitle['type'] != 1 ||
          subtitle['subtitle_url'] == null ||
          (subtitle['subtitle_url'] is String &&
              (subtitle['subtitle_url'] as String).trim().isEmpty)) {
        continue;
      }
      final Object? rawId = subtitle['id_str'] ?? subtitle['id'];
      final String id = rawId is int && rawId >= 0
          ? rawId.toString()
          : _nonEmptyString(rawId);
      tracks.add(
        BiliSubtitleTrack(
          id: id,
          language: _nonEmptyString(subtitle['lan']),
          label: _nonEmptyString(subtitle['lan_doc']),
          url: _subtitleUrl(subtitle['subtitle_url']),
          isTranslated: subtitle['ai_type'] == 1,
        ),
      );
    }
    return tracks;
  }

  Future<List<BiliSubtitleLine>> fetchLines(BiliSubtitleTrack track) async {
    final String url = _subtitleUrl(track.url);
    final Response<dynamic> response = await _client.get<dynamic>(
      url,
      mode: BiliRequestMode.anonymous,
      options: Options(followRedirects: false),
    );
    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw const BiliSubtitleException('Subtitle download failed.');
    }
    Object? payload = response.data;
    if (payload is String) {
      try {
        payload = jsonDecode(payload);
      } on FormatException {
        throw const BiliSubtitleException('Invalid subtitle JSON.');
      }
    }
    final Object? body = _asMap(payload)['body'];
    if (body is! List) {
      throw const BiliSubtitleException('Invalid subtitle body.');
    }
    final List<({int index, BiliSubtitleLine line})> lines = [];
    for (int index = 0; index < body.length; index++) {
      final Map<String, dynamic> value = _asMap(body[index]);
      final int startMs = _milliseconds(value['from']);
      final int endMs = _milliseconds(value['to']);
      if (endMs <= startMs) {
        throw const BiliSubtitleException('Invalid subtitle time range.');
      }
      lines.add((
        index: index,
        line: BiliSubtitleLine(
          startMs: startMs,
          endMs: endMs,
          text: _nonEmptyString(value['content']),
        ),
      ));
    }
    lines.sort((left, right) {
      final int order = left.line.startMs.compareTo(right.line.startMs);
      return order != 0 ? order : left.index.compareTo(right.index);
    });
    return lines.map((entry) => entry.line).toList(growable: false);
  }

  Map<String, dynamic> _asMap(Object? value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliSubtitleException('Invalid subtitle response.');
    }
  }

  String _nonEmptyString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const BiliSubtitleException('Invalid subtitle text or metadata.');
    }
    return value.trim();
  }

  String _subtitleUrl(Object? value) {
    final String raw = _nonEmptyString(value);
    final String url = raw.startsWith('//') ? 'https:$raw' : raw;
    final Uri? uri = Uri.tryParse(url);
    if (!RegExp(
          r'^https://[a-z0-9.-]+(?:/|\?|$)',
          caseSensitive: false,
        ).hasMatch(url) ||
        RegExp(r'[\x00-\x20\x7f\\]').hasMatch(url) ||
        uri == null ||
        uri.scheme != 'https' ||
        !uri.hasAuthority ||
        uri.authority.contains('@') ||
        uri.authority.contains(':') ||
        uri.hasFragment ||
        uri.host.length > 253 ||
        !RegExp(
          r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+(?:hdslb|bilibili)\.com$',
        ).hasMatch(uri.host)) {
      throw const BiliSubtitleException('Untrusted subtitle URL.');
    }
    return uri.toString();
  }

  int _milliseconds(Object? value) {
    if (value is! num || !value.isFinite || value < 0) {
      throw const BiliSubtitleException('Invalid subtitle timestamp.');
    }
    final double milliseconds = value.toDouble() * 1000;
    if (!milliseconds.isFinite || milliseconds > 9007199254740991) {
      throw const BiliSubtitleException('Subtitle timestamp is out of range.');
    }
    return milliseconds.round();
  }
}

class BiliSubtitleException implements Exception {
  const BiliSubtitleException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}
