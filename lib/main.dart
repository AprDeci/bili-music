import 'package:bilimusic/core/hive/hive.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  await initHive();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: MyApp()));
}
