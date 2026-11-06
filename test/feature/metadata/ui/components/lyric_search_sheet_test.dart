import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_search_sheet.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_preference.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('car opens lyric search in a full-height left side panel', (
    tester,
  ) async {
    final controller = await _openSearch(tester, AppLayout.car);

    expect(find.byType(CarSidePanel), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    final panel = tester.getRect(find.byType(CarSidePanel));
    expect(panel.left, closeTo(24, 0.01));
    expect(panel.top, closeTo(24, 0.01));
    expect(panel.bottom, closeTo(776, 0.01));
    expect(panel.center.dx, lessThan(600));
    expect(tester.getSize(find.byType(ListView)).height, greaterThan(420));
    expect(controller.searches, [('测试歌曲', MetingServer.netease)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'car keyboard leaves results scrollable and selection applies then closes',
    (tester) async {
      var appliedCount = 0;
      final controller = await _openSearch(
        tester,
        AppLayout.car,
        onApplied: () => appliedCount++,
      );
      final list = find.byType(ListView);
      final initialHeight = tester.getSize(list).height;

      await tester.showKeyboard(find.byType(TextField).first);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.getSize(list).height, closeTo(initialHeight - 280, 0.01));
      expect(tester.getRect(list).bottom, lessThanOrEqualTo(800 - 280));
      expect(tester.takeException(), isNull);

      final scrollable = find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('搜索结果 29'),
        200,
        scrollable: scrollable,
      );
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );
      await tester.tap(find.text('搜索结果 29'));
      await tester.pumpAndSettle();

      expect(controller.applied?.id, '29');
      expect(appliedCount, 1);
      expect(find.byType(CarSidePanel), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.text('打开歌词搜索'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final layout in [AppLayout.mobile, AppLayout.desktop]) {
    testWidgets('${layout.name} keeps lyric search in a bottom sheet', (
      tester,
    ) async {
      await _openSearch(tester, layout);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CarSidePanel), findsNothing);
      final sheet = tester.getRect(find.byType(BottomSheet));
      final screenSize = tester.view.physicalSize;
      expect(sheet.bottom, closeTo(screenSize.height, 0.01));
      expect(sheet.top, greaterThan(0));
      expect(sheet.height, closeTo(452, 0.01));
      expect(find.text('搜索结果 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<_MetadataController> _openSearch(
  WidgetTester tester,
  AppLayout layout, {
  VoidCallback? onApplied,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = layout == AppLayout.mobile
      ? const Size(420, 900)
      : const Size(1200, 800);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final controller = _MetadataController();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataControllerProvider.overrideWith(() => controller),
        playerControllerProvider.overrideWith(_Player.new),
        metingSourcePreferenceLogicProvider.overrideWithValue(
          const MetingSourcePreference(),
        ),
        metingRepositoryProvider.overrideWithValue(const _MetingRepository()),
      ],
      child: MaterialApp(
        home: AppLayoutScope(
          layout: layout,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showManualLyricSearchSheet(
                  context: context,
                  initialKeyword: '测试歌曲',
                  onApplied: onApplied,
                ),
                child: const Text('打开歌词搜索'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开歌词搜索'));
  await tester.pumpAndSettle();
  return controller;
}

class _Player extends PlayerController {
  @override
  PlayerState build() => PlayerState();
}

class _MetadataController extends MetadataController {
  final searches = <(String, MetingServer?)>[];
  MetingSearchItem? applied;

  @override
  MetadataState build() => const MetadataState();

  @override
  Future<void> searchManual(String keyword, {MetingServer? server}) async {
    searches.add((keyword, server));
    state = state.copyWith(
      searchKeyword: keyword,
      searchResults: List.generate(
        30,
        (index) => MetingSearchItem(
          id: '$index',
          title: '搜索结果 $index',
          author: '歌手 $index',
          server: server ?? MetingServer.netease,
        ),
      ),
    );
  }

  @override
  Future<void> applyManualResult(MetingSearchItem item) async {
    applied = item;
  }
}

class _MetingRepository extends MetingRepository {
  const _MetingRepository();

  @override
  Future<String> fetchPicture(MetingSearchItem item, {int size = 300}) async =>
      '';
}
