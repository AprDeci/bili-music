import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
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
      const LyricPreset base = LyricPresets.appleMusic;
      expect(
        view.preset!.copyWith(
          textStyle: base.textStyle,
          translationTextStyle: base.translationTextStyle,
          activeTranslationTextStyle: base.activeTranslationTextStyle,
          highlight: base.highlight,
          countdown: base.countdown,
          clearSelectedTextColor: true,
          clearSelectedTranslationTextColor: true,
          clearSelectionForegroundBuilder: true,
        ),
        base,
      );
      expect(
        view.preset!.textStyle.copyWith(color: base.textStyle.color),
        base.textStyle,
      );
      expect(
        view.preset!.translationTextStyle.copyWith(
          color: base.translationTextStyle.color,
        ),
        base.translationTextStyle,
      );
      final LyricController controller = view.controller;
      expect(controller.timeOffset, const Duration(milliseconds: 300));
      expect(controller.document!.offset, const Duration(milliseconds: 200));
      expect(controller.position, const Duration(seconds: 2));
      expect(controller.activeLineIndex, 0);
      expect(controller.document!.lines.first.translation, '翻译一');

      final Rect viewport = tester.getRect(find.byType(LyricView));
      await tester.tapAt(
        Offset(
          viewport.center.dx,
          viewport.top +
              LyricPresets.appleMusic.activeAnchor.resolve(viewport.height),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
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
      await tester.pump(const Duration(seconds: 1));
      expect(seeks, hasLength(2));
      expect(seeks.last.inMilliseconds % 1000, 500);
      expect(
        timestamp,
        '00:${seeks.last.inSeconds.toString().padLeft(2, '0')}',
      );
      expect(playButton, findsNothing);
    });
  }

  for (final PlayerLyricPanelVariant variant
      in PlayerLyricPanelVariant.values) {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('${variant.name} lyrics adapt to $brightness backgrounds', (
        WidgetTester tester,
      ) async {
        Color? previousHighlight;
        LyricDocument? document;
        for (final Color seed in <Color>[
          Colors.white,
          Colors.black,
          Colors.cyan,
          Colors.red,
        ]) {
          await _pumpPanel(
            tester,
            variant: variant,
            activeColor: seed,
            brightness: brightness,
          );
          await tester.pump(const Duration(seconds: 1));
          final LyricView view = tester.widget<LyricView>(
            find.byType(LyricView),
          );
          final LyricPreset preset = view.preset!;
          final Color highlight = preset.highlight.color!;
          final DecoratedBox background = tester.widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(PlayerDynamicBackdrop),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          );
          final LinearGradient gradient =
              (background.decoration as BoxDecoration).gradient!
                  as LinearGradient;
          final List<double> luminances = <double>[
            highlight.computeLuminance(),
            gradient.colors[1].computeLuminance(),
          ]..sort();
          expect(
            (luminances.last + 0.05) / (luminances.first + 0.05),
            greaterThanOrEqualTo(3),
            reason:
                '$seed highlighted lyrics need contrast on the actual backdrop',
          );
          expect(preset.countdown.color, highlight);
          expect(preset.activeTranslationTextStyle.color, highlight);
          expect(
            preset.textStyle.color!.computeLuminance(),
            brightness == Brightness.light ? lessThan(0.1) : greaterThan(0.6),
          );
          if (previousHighlight != null && seed != Colors.black) {
            expect(highlight, isNot(previousHighlight));
          }
          if (document != null) {
            expect(view.controller.document, same(document));
          }
          document = view.controller.document;
          previousHighlight = highlight;
        }
      });
    }
  }

  testWidgets('uses theme colors until a cover color is available', (
    WidgetTester tester,
  ) async {
    await _pumpPanel(tester);
    final LyricPreset preset = tester
        .widget<LyricView>(find.byType(LyricView))
        .preset!;
    final ColorScheme colors = Theme.of(
      tester.element(find.byType(LyricView)),
    ).colorScheme;
    expect(preset.highlight.color, colors.primary);
    expect(preset.selectedTextColor, colors.onSurface);
    expect(preset.textStyle.color, colors.onSurface.withValues(alpha: 0.6));
  });

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
    await tester.pump(const Duration(seconds: 1));
    expect(controller.document, isNull);
    expect(find.text('暂无歌词'), findsOneWidget);
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  PlayerLyricPanelVariant variant = PlayerLyricPanelVariant.mobile,
  Duration position = const Duration(seconds: 2),
  bool showTranslation = true,
  Color? activeColor,
  Brightness brightness = Brightness.light,
  ValueChanged<Duration>? onSeek,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataControllerProvider.overrideWith(_MetadataController.new),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PlayerDynamicBackdrop(baseColor: activeColor),
              Center(
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
                    activeColor: activeColor,
                    showTranslation: showTranslation,
                    onSeek: onSeek ?? (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // Apple Music 持续浮动，不会进入 pumpAndSettle 等待的静止状态。
  await tester.pump(const Duration(seconds: 1));
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
