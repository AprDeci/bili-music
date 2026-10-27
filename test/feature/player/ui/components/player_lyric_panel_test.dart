import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: '测试歌曲',
  author: '测试歌手',
  coverUrl: '',
);

const String _lyrics =
    '[offset:200]\n[00:01.000]第一行\n[00:04.000]第二行\n'
    '[00:07.000]第三行\n[00:10.000]第四行';

void main() {
  for (final PlayerLyricPanelVariant variant
      in PlayerLyricPanelVariant.values) {
    testWidgets('${variant.name} seeks using both lyric offsets', (
      WidgetTester tester,
    ) async {
      final List<Duration> seeks = <Duration>[];
      await _pumpPanel(tester, variant: variant, onSeek: seeks.add);
      final LyricView view = tester.widget<LyricView>(find.byType(LyricView));
      final LyricController controller = view.controller;
      expect(controller.timeOffset, const Duration(milliseconds: 300));
      expect(controller.document!.offset, const Duration(milliseconds: 200));
      expect(controller.position, const Duration(seconds: 2));
      expect(controller.activeLineIndex, 0);
      expect(controller.document!.lines.first.translation, '翻译一');

      final Rect viewport = tester.getRect(find.byType(LyricView));
      await tester.tapAt(
        Offset(viewport.center.dx, viewport.top + viewport.height * 0.42),
      );
      await tester.pumpAndSettle();
      expect(seeks, <Duration>[const Duration(milliseconds: 500)]);

      await tester.drag(find.byType(LyricView), const Offset(0, -100));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      final Finder playButton = find.byIcon(Icons.play_arrow_rounded);
      expect(playButton, findsOneWidget);
      final String timestamp = tester
          .widget<Text>(
            find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Text &&
                  RegExp(r'^\d+:\d{2}$').hasMatch(widget.data ?? ''),
            ),
          )
          .data!;
      await tester.tap(playButton);
      await tester.pumpAndSettle();
      expect(seeks, hasLength(2));
      expect(seeks.last.inMilliseconds % 1000, 500);
      expect(
        timestamp,
        '00:${seeks.last.inSeconds.toString().padLeft(2, '0')}',
      );
      expect(playButton, findsNothing);
    });
  }

  testWidgets('updates position and translation without replacing controller', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester);
    final LyricController controller = tester
        .widget<LyricView>(find.byType(LyricView))
        .controller;
    expect(controller.document!.lines.first.translation, '翻译一');

    await _pumpPanel(
      tester,
      position: const Duration(seconds: 5),
      showTranslation: false,
    );
    expect(
      tester.widget<LyricView>(find.byType(LyricView)).controller,
      same(controller),
    );
    expect(controller.position, const Duration(seconds: 5));
    expect(controller.activeLineIndex, 1);
    expect(controller.document!.lines.first.translation, isNull);
  });

  testWidgets('clears the loaded document when lyrics disappear', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester);
    final LyricController controller = tester
        .widget<LyricView>(find.byType(LyricView))
        .controller;
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(PlayerLyricPanel)),
    );
    (container.read(metadataControllerProvider.notifier) as _MetadataController)
        .clearLyrics();
    await tester.pumpAndSettle();
    expect(controller.document, isNull);
    expect(find.text('暂无歌词'), findsOneWidget);
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  PlayerLyricPanelVariant variant = PlayerLyricPanelVariant.mobile,
  Duration position = const Duration(seconds: 2),
  bool showTranslation = true,
  ValueChanged<Duration>? onSeek,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataControllerProvider.overrideWith(_MetadataController.new),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 500,
              child: PlayerLyricPanel(
                state: PlayerState(
                  position: position,
                  duration: const Duration(seconds: 15),
                ),
                item: _item,
                isActive: true,
                variant: variant,
                showTranslation: showTranslation,
                onSeek: onSeek ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MetadataController extends MetadataController {
  @override
  MetadataState build() => MetadataState(
    stableId: _item.stableId,
    metadata: Metadata(
      stableId: _item.stableId,
      lyricOffsetMs: 300,
      metaLyrics: const MetaLyrics(
        lyric: _lyrics,
        translatedLyric: '[00:01.000]翻译一\n[00:04.000]翻译二',
      ),
    ),
  );

  void clearLyrics() => state = MetadataState(stableId: _item.stableId);
}
