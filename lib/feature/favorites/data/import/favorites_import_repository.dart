import 'dart:convert';

import 'package:bilimusic/feature/favorites/domain/import/favorites_import_platform.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_track.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class FavoritesImportRepository {
  const FavoritesImportRepository({
    required this._metingRepository,
    required this._biliSearchRepository,
  });

  final MetingRepository _metingRepository;
  final BiliSearchRepository _biliSearchRepository;

  Future<List<FavoritesImportTrack>> fetchPlaylistTracks({
    required String playlistId,
    required FavoritesImportPlatform platform,
  }) async {
    final String trimmedPlaylistId = playlistId.trim();
    if (trimmedPlaylistId.isEmpty) {
      return const <FavoritesImportTrack>[];
    }

    final Object? response = await _metingRepository.fetchPlaylist(
      playlistId: trimmedPlaylistId,
      server: platform.metingServer,
    );
    final List<dynamic> rawItems = _decodeList(response);
    final List<FavoritesImportTrack> tracks = <FavoritesImportTrack>[];
    for (final dynamic rawItem in rawItems) {
      final Map<String, dynamic>? json = _asMap(rawItem);
      if (json == null) {
        continue;
      }

      final String title = _readString(json['title'] ?? json['name']);
      final String author = _readAuthor(json['artist'] ?? json['author']);
      final int durationMs = _readDurationMs(json['duration']);
      if (title.trim().isEmpty && author.trim().isEmpty) {
        continue;
      }

      tracks.add(
        FavoritesImportTrack(
          id: _readString(json['id'] ?? json['url_id'] ?? json['lyric_id']),
          title: title,
          author: author,
          durationMs: durationMs,
        ),
      );
    }

    return tracks;
  }

  Future<List<SearchResultItem>> searchVideos(String keyword) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return const <SearchResultItem>[];
    }
    return _biliSearchRepository
        .searchVideos(trimmedKeyword)
        .then((value) => value.items);
  }

  List<dynamic> _decodeList(Object? response) {
    if (response is String) {
      final Object? decoded = jsonDecode(response);
      return decoded is List ? decoded : const <dynamic>[];
    }
    if (response is List) {
      return response;
    }
    return const <dynamic>[];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic entry) => MapEntry(key.toString(), entry),
      );
    }
    return null;
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _readAuthor(dynamic value) {
    if (value is List) {
      return value
          .where((dynamic item) => item != null)
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .join(' / ');
    }
    return _readString(value);
  }

  int _readDurationMs(dynamic value) {
    if (value is Duration) {
      return value.inMilliseconds;
    }
    if (value is num) {
      final int raw = value.toInt();
      if (raw <= 0) {
        return 0;
      }
      return _normalizeDurationMs(raw);
    }
    final int? parsed = int.tryParse(_readString(value));
    if (parsed == null || parsed <= 0) {
      return 0;
    }
    return _normalizeDurationMs(parsed);
  }

  int _normalizeDurationMs(int raw) {
    return raw >= 10000 ? raw : raw * 1000;
  }
}
