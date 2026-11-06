import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/ui/downloads_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the empty state when nothing is downloaded', (
    tester,
  ) async {
    await _pump(tester, const DownloadState());

    expect(find.text('还没有下载的歌曲'), findsOneWidget);
    expect(find.byTooltip('多选'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  for (final double width in <double>[320, 1200]) {
    testWidgets('matches favorite list dimensions at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pump(tester, DownloadState(tracks: _tracks, totalBytes: 3072));

      expect(find.textContaining('已下载 2 首'), findsOneWidget);
      expect(find.text('夜曲'), findsOneWidget);
      expect(find.textContaining('周杰伦'), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('删除下载'), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      final CommonCachedImage image = tester.widget<CommonCachedImage>(
        find.byType(CommonCachedImage).first,
      );
      expect(image.width, 44);
      expect(image.height, 44);
      final Finder tile = find.ancestor(
        of: find.text('夜曲'),
        matching: find.byType(ListTile),
      );
      final ListTile widget = tester.widget<ListTile>(tile);
      expect(widget.contentPadding, const EdgeInsets.symmetric(horizontal: 14));
      final double tileHeight = tester.getSize(tile).height;
      final Offset imagePosition = tester.getTopLeft(
        find.byType(CommonCachedImage).first,
      );

      await tester.longPress(find.text('夜曲'));
      await tester.pumpAndSettle();
      expect(find.text('已选 1 项'), findsOneWidget);
      expect(tester.getSize(tile).height, tileHeight);
      expect(
        tester.getTopLeft(find.byType(CommonCachedImage).first),
        imagePosition,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports multi-select, select all, deselect and exit', (
    tester,
  ) async {
    await _pump(tester, DownloadState(tracks: _tracks));
    await tester.tap(find.byTooltip('多选'));
    await tester.pumpAndSettle();

    expect(find.text('已选 0 项'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '删除所选下载',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('全选'));
    await tester.pump();
    expect(find.text('已选 2 项'), findsOneWidget);
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .every((box) => box.value!),
      isTrue,
    );
    await tester.tap(find.text('取消全选'));
    await tester.pump();
    expect(find.text('已选 0 项'), findsOneWidget);
    await tester.tap(find.text('夜曲'));
    await tester.pump();
    expect(find.text('已选 1 项'), findsOneWidget);
    await tester.tap(find.byTooltip('退出批量操作'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.byTooltip('多选'));
    await tester.pump();
    expect(find.text('已选 0 项'), findsOneWidget);
  });

  testWidgets('confirms deletion and removes only selected tracks', (
    tester,
  ) async {
    final controller = await _pump(tester, DownloadState(tracks: _tracks));
    await tester.longPress(find.text('夜曲'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除所选下载'));
    await tester.pumpAndSettle();
    expect(find.text('将删除所选的 1 首歌曲文件，确认继续？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(controller.removed, isEmpty);
    expect(find.text('已选 1 项'), findsOneWidget);

    await tester.tap(find.byTooltip('删除所选下载'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(controller.removed, <String>['bvid:BV1:page:1']);
    expect(find.text('夜曲'), findsNothing);
    expect(find.text('晴天'), findsOneWidget);
    expect(find.byTooltip('多选'), findsOneWidget);
    final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('clear downloads preserves active tasks', (tester) async {
    final controller = await _pump(
      tester,
      DownloadState(
        tracks: _tracks,
        tasks: const <String, DownloadTask>{
          'new': DownloadTask(
            contentId: 'new',
            status: DownloadTaskStatus.running,
            receivedBytes: 50,
            totalBytes: 100,
          ),
        },
      ),
    );
    expect(find.text('下载中 50%'), findsOneWidget);
    await tester.tap(find.byTooltip('清空下载'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(FilledButton, '清空'));
    await tester.pumpAndSettle();
    expect(controller.removed, hasLength(2));
    expect(find.text('夜曲'), findsNothing);
    expect(find.text('晴天'), findsNothing);
    expect(find.text('下载中 50%'), findsOneWidget);
    expect(find.text('还没有下载的歌曲'), findsNothing);
    final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('prunes selection when downloads change externally', (
    tester,
  ) async {
    final controller = await _pump(tester, DownloadState(tracks: _tracks));
    await tester.longPress(find.text('夜曲'));
    await tester.pumpAndSettle();
    controller.replace(DownloadState(tracks: <DownloadedTrack>[_tracks.last]));
    await tester.pumpAndSettle();
    expect(find.text('已选 0 项'), findsOneWidget);
    controller.replace(const DownloadState());
    await tester.pumpAndSettle();
    expect(find.text('还没有下载的歌曲'), findsOneWidget);
    expect(find.byTooltip('退出批量操作'), findsNothing);
  });
}

Future<_DownloadController> _pump(
  WidgetTester tester,
  DownloadState state,
) async {
  final controller = _DownloadController(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [downloadControllerProvider.overrideWith(() => controller)],
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        home: const DownloadsPage(),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

class _DownloadController extends DownloadController {
  _DownloadController(this.initialState);

  final DownloadState initialState;
  final List<String> removed = <String>[];

  @override
  DownloadState build() => initialState;

  void replace(DownloadState next) => state = next;

  @override
  Future<void> removeTrack(DownloadedTrack track) async {
    removed.add(track.contentId);
    state = state.copyWith(
      tracks: state.tracks
          .where((item) => item.contentId != track.contentId)
          .toList(),
    );
  }
}

final List<DownloadedTrack> _tracks = <DownloadedTrack>[
  for (int index = 1; index <= 2; index++)
    DownloadedTrack(
      contentId: 'bvid:BV$index:page:1',
      aid: index,
      bvid: 'BV$index',
      cid: index * 10,
      page: 1,
      title: index == 1 ? '夜曲' : '晴天',
      author: '周杰伦',
      coverUrl: '',
      filePath: '/unused/$index.m4a',
      byteLength: 1024 * index,
      downloadedAtMs: index,
      qualityLabel: '192K',
    ),
];
