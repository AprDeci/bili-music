import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  if (!kIsWeb) {
    final Directory directory = await getTemporaryDirectory();
    Hive
      ..init(directory.path)
      ..registerAdapter(ThemeUiModelAdapter());
  }
  await Hive.openBox<String>('prefs');
}
