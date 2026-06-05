import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/favorites/data/bili_favorites_remote_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_remote_cache_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_favorites_repositories.g.dart';

@riverpod
FavoritesRemoteCacheRepository favoritesRemoteCacheRepository(Ref ref) {
  return FavoritesRemoteCacheRepository(
    collectionsBox: Hive.box<FavoriteCollection>(
      remoteFavoriteCollectionsBoxName,
    ),
    entriesBox: Hive.box<FavoriteEntry>(remoteFavoriteEntriesBoxName),
    membershipsBox: Hive.box<FavoriteMembership>(
      remoteFavoriteMembershipsBoxName,
    ),
  );
}

@riverpod
BiliFavoritesRemoteRepository biliFavoritesRemoteRepository(Ref ref) {
  return BiliFavoritesRemoteRepository(
    apiClient: ref.read(biliApiClientProvider),
    client: ref.read(biliClientProvider.notifier),
  );
}
