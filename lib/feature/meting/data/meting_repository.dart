import 'dart:convert';

import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:meting_dart/meting_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_repository.g.dart';

@riverpod
MetingRepository metingRepository(Ref ref) {
  return const MetingRepository();
}

typedef MetingSearchRequest =
    Future<Object?> Function({
      required MetingServer server,
      required String keyword,
      required Map<String, dynamic> option,
    });

typedef MetingLyricRequest =
    Future<Object?> Function({
      required MetingServer server,
      required String id,
    });

typedef MetingPictureRequest =
    Future<Object?> Function({
      required MetingServer server,
      required String id,
      required int size,
    });

class MetingRepository {
  const MetingRepository({
    MetingSearchRequest searchRequest = _defaultSearchRequest,
    MetingLyricRequest lyricRequest = _defaultLyricRequest,
    MetingPictureRequest pictureRequest = _defaultPictureRequest,
  }) : this._(
         searchRequest: searchRequest,
         lyricRequest: lyricRequest,
         pictureRequest: pictureRequest,
       );

  const MetingRepository._({
    required this._searchRequest,
    required this._lyricRequest,
    required this._pictureRequest,
  });

  final MetingSearchRequest _searchRequest;
  final MetingLyricRequest _lyricRequest;
  final MetingPictureRequest _pictureRequest;

  Future<List<MetingSearchItem>> search({
    required String keyword,
    MetingServer server = MetingServer.netease,
  }) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return const <MetingSearchItem>[];
    }

    try {
      final Object? response = await _searchRequest(
        server: server,
        keyword: trimmedKeyword,
        option: const <String, dynamic>{'limit': 10},
      );
      final Object? data = _decodeFormattedResponse(response);
      if (data is! List<dynamic>) {
        throw const MetingException('Meting 搜索返回格式异常。');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> json) => _mapSearchItem(json, server))
          .toList(growable: false);
    } on MetingException {
      rethrow;
    } on Object catch (error) {
      throw MetingException('Meting 搜索失败：$error');
    }
  }

  Future<String> fetchLyrics(MetingSearchItem item) async {
    final String id = item.id.trim();
    if (id.isEmpty) {
      throw const MetingException('当前歌曲没有歌词 ID。');
    }

    try {
      final Object? response = await _lyricRequest(server: item.server, id: id);
      final Object? data = _decodeFormattedResponse(response);
      if (data is Map<String, dynamic>) {
        return _readString(data['lyric']);
      }
      throw const MetingException('Meting 歌词返回格式异常。');
    } on MetingException {
      rethrow;
    } on Object catch (error) {
      throw MetingException('Meting 歌词请求失败：$error');
    }
  }

  Future<String> fetchPicture(MetingSearchItem item, {int size = 300}) async {
    final String id = (item.picId?.trim().isNotEmpty ?? false)
        ? item.picId!.trim()
        : item.id.trim();
    if (id.isEmpty) {
      throw const MetingException('当前歌曲没有封面 ID。');
    }

    try {
      final Object? response = await _pictureRequest(
        server: item.server,
        id: id,
        size: size,
      );
      final Object? data = _decodeFormattedResponse(response);
      if (data is Map<String, dynamic>) {
        return _readString(data['url']);
      }
      if (data is String) {
        return data;
      }
      throw const MetingException('Meting 封面返回格式异常。');
    } on MetingException {
      rethrow;
    } on Object catch (error) {
      throw MetingException('Meting 封面请求失败：$error');
    }
  }

  MetingSearchItem _mapSearchItem(
    Map<String, dynamic> json,
    MetingServer server,
  ) {
    return MetingSearchItem(
      id: _readString(json['lyric_id']).isNotEmpty
          ? _readString(json['lyric_id'])
          : _readString(json['id']),
      title: _readString(json['name'] ?? json['title']),
      author: _readAuthor(json['artist'] ?? json['author']),
      server: server,
      picId: _readString(json['pic_id']),
    );
  }

  Object? _decodeFormattedResponse(Object? value) {
    if (value is String) {
      return jsonDecode(value);
    }
    return value;
  }

  String _readAuthor(Object? value) {
    if (value is List<dynamic>) {
      return value
          .whereType<Object>()
          .map((Object item) => item.toString())
          .where((String item) => item.isNotEmpty)
          .join(' / ');
    }
    return _readString(value);
  }

  String _readString(Object? value) {
    return value is String ? value : '';
  }
}

Future<Object?> _defaultSearchRequest({
  required MetingServer server,
  required String keyword,
  required Map<String, dynamic> option,
}) {
  final Meting meting = Meting(server: server.apiValue)..format(true);
  return meting.search(keyword, option: option);
}

Future<Object?> _defaultLyricRequest({
  required MetingServer server,
  required String id,
}) {
  final Meting meting = Meting(server: server.apiValue)..format(true);
  return meting.lyric(id);
}

Future<Object?> _defaultPictureRequest({
  required MetingServer server,
  required String id,
  required int size,
}) {
  final Meting meting = Meting(server: server.apiValue)..format(true);
  return meting.pic(id, size: size);
}

class MetingException implements Exception {
  const MetingException(this.message);

  final String message;

  @override
  String toString() => message;
}
