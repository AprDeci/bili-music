import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_cache_entry.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyrics_cache_repository.g.dart';

@riverpod
PlayerLyricsCacheRepository playerLyricsCacheRepository(Ref ref) {
  return PlayerLyricsCacheRepository(AppLyricsCacheManager.instance);
}

class PlayerLyricsCacheRepository {
  PlayerLyricsCacheRepository(this._cacheManager);

  final CacheManager _cacheManager;

  String buildCacheKey({required PlayableItem item}) {
    return 'lyrics:${item.stableId}';
  }

  Future<PlayerLyricsCacheEntry?> getCachedEntry({
    required PlayableItem item,
  }) async {
    final String key = buildCacheKey(item: item);
    final FileInfo? fileInfo = await _cacheManager.getFileFromCache(key);
    if (fileInfo == null) {
      return null;
    }

    if (!await fileInfo.file.exists()) {
      await _cacheManager.removeFile(key);
      return null;
    }

    try {
      final String content = await fileInfo.file.readAsString();
      final dynamic decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        await _cacheManager.removeFile(key);
        return null;
      }

      final PlayerLyricsCacheEntry entry = PlayerLyricsCacheEntry.fromJson(
        decoded,
      );
      if (entry.stableId != item.stableId) {
        await _cacheManager.removeFile(key);
        return null;
      }
      return entry;
    } on FormatException {
      await _cacheManager.removeFile(key);
      return null;
    } on FileSystemException {
      await _cacheManager.removeFile(key);
      return null;
    } on Object {
      await _cacheManager.removeFile(key);
      return null;
    }
  }

  Future<void> saveEntry(PlayerLyricsCacheEntry entry) async {
    final String key = 'lyrics:${entry.stableId}';
    final Uint8List bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(entry.toJson())),
    );
    await _cacheManager.putFile(key, bytes, fileExtension: 'json');
  }

  Future<void> removeCachedEntry({required PlayableItem item}) {
    return _cacheManager.removeFile(buildCacheKey(item: item));
  }
}
