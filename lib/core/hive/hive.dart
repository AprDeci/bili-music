import 'dart:io';

import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (!kIsWeb) {
    final Directory directory = await getApplicationDocumentsDirectory();
    Hive
      ..init(directory.path)
      ..registerAdapter(FavoriteCollectionAdapter())
      ..registerAdapter(FavoriteEntryAdapter())
      ..registerAdapter(FavoriteMembershipAdapter())
      ..registerAdapter(PlayerQueueModeAdapter())
      ..registerAdapter(PersistedPlayableItemAdapter())
      ..registerAdapter(PersistedPlaybackQueueAdapter())
      ..registerAdapter(RecentPlaybackEntryAdapter())
      ..registerAdapter(MetaLyricsAdapter())
      ..registerAdapter(MetadataAdapter());
  }
  await Hive.openBox<String>(HiveBoxNames.prefs);
  await Hive.openBox<FavoriteCollection>(favoriteCollectionsBoxName);
  await Hive.openBox<FavoriteEntry>(favoriteEntriesBoxName);
  await Hive.openBox<FavoriteMembership>(favoriteMembershipsBoxName);
  await Hive.openBox<PersistedPlaybackQueue>(playerQueueSnapshotBoxName);
  await Hive.openBox<RecentPlaybackEntry>(recentPlaybackBoxName);
  await Hive.openBox<Metadata>(metadataCacheBoxName);
}
