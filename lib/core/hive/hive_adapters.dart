import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters(<AdapterSpec<dynamic>>[
  AdapterSpec<ThemeUiModel>(),
  AdapterSpec<FavoriteCollection>(),
  AdapterSpec<FavoriteEntry>(),
  AdapterSpec<FavoriteMembership>(),
])
part 'hive_adapters.g.dart';
