import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (!kIsWeb) {
    final Directory directory = await getApplicationDocumentsDirectory();
    Hive
      ..init(directory.path)
      ..registerAdapter(ThemeUiModelAdapter())
      ..registerAdapter(FavoriteCollectionAdapter())
      ..registerAdapter(FavoriteEntryAdapter())
      ..registerAdapter(FavoriteMembershipAdapter());
  }
  await Hive.openBox<String>('prefs');
  await Hive.openBox<FavoriteCollection>(favoriteCollectionsBoxName);
  await Hive.openBox<FavoriteEntry>(favoriteEntriesBoxName);
  await Hive.openBox<FavoriteMembership>(favoriteMembershipsBoxName);
}
