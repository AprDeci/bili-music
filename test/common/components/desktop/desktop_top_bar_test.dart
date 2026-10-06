import 'dart:io';

import 'package:bilimusic/common/components/desktop/desktop_top_bar.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  const MethodChannel windowManagerChannel = MethodChannel('window_manager');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'bilimusic_desktop_top_bar_test',
    );
    Hive.init(tempDirectory.path);
    await Hive.openBox<String>(HiveBoxNames.prefs);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, (
          MethodCall call,
        ) async {
          if (call.method == 'isMaximized') {
            return false;
          }
          return null;
        });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowManagerChannel, null);
    await Hive.close();
  });

  testWidgets(
    'macOS 顶部栏不再绘制窗口操作按钮',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: DesktopTopBar())),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.remove_rounded), findsNothing);
      expect(find.byIcon(Icons.crop_square_rounded), findsNothing);
      expect(find.byIcon(Icons.filter_none_rounded), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.text('搜索音乐'), findsOneWidget);
    },
    // 该断言只针对 macOS 布局，其他平台跳过。
    skip: !Platform.isMacOS,
  );
}
