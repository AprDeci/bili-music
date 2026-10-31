import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
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

const BiliSubtitleTrack _subtitleTrack = BiliSubtitleTrack(
  id: 'ai-zh',
  language: 'ai-zh',
  label: 'AI中文字幕',
  url: 'https://example.com/subtitle.json',
);

void main() {
  testWidgets(
    'same content switching to spoken clears music but keeps subtitles',
    (tester) async {
      await _pumpPanel(tester);
      final controller = tester
          .widget<LyricView>(find.byType(LyricView))
          .controller;
      await _pumpPanel(
        tester,
        item: _item.copyWith(kind: CollectionKind.spoken),
      );
      expect(find.byType(LyricView), findsNothing);
      expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
      expect(controller.document, isNull);
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(PlayerLyricPanel)),
      );
      final _NoSubtitles subtitles =
          container.read(playerSubtitleControllerProvider.notifier)
              as _NoSubtitles;
      subtitles.setSubtitles(_AiSubtitles().build());
      await tester.pump();
      expect(find.byType(LyricView), findsOneWidget);
      expect(
        tester
            .widget<LyricView>(find.byType(LyricView))
            .controller
            .document!
            .lines
            .any((line) => line.text == 'AI字幕第一行'),
        isTrue,
      );
    },
  );

  for (final PlayerLyricPanelVariant variant
      in PlayerLyricPanelVariant.values) {
    testWidgets(
      '${variant.name} subtitles discover download render and stop loading',
      (tester) async {
        await _pumpPanel(
          tester,
          variant: variant,
          item: _item.copyWith(kind: CollectionKind.spoken),
        );
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(PlayerLyricPanel)),
        );
        final _NoSubtitles subtitles =
            container.read(playerSubtitleControllerProvider.notifier)
                as _NoSubtitles;
        Future<void> show(PlayerSubtitleState state) async {
          subtitles.setSubtitles(state);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }

        final PlayerSubtitleState discovering = PlayerSubtitleState(
          stableId: _item.stableId,
          isDiscovering: true,
        );
        await show(discovering);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('正在加载字幕'), findsOneWidget);
        expect(find.text('当前视频没有可用歌词|字幕'), findsNothing);
        final PlayerSubtitleState downloading = discovering.copyWith(
          isDiscovering: false,
          tracks: const <BiliSubtitleTrack>[_subtitleTrack],
          pendingTrackId: _subtitleTrack.id,
        );
        await show(downloading);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(LyricView), findsNothing);
        final PlayerSubtitleState loaded = _AiSubtitles().build().copyWith(
          tracks: downloading.tracks,
        );
        await show(loaded);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(LyricView), findsOneWidget);
        final LyricController controller = tester
            .widget<LyricView>(find.byType(LyricView))
            .controller;
        final LyricDocument document = controller.document!;
        expect(document.lines.first.text, 'AI字幕第一行');
        await show(loaded.copyWith(pendingTrackId: _subtitleTrack.id));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(LyricView), findsOneWidget);
        expect(controller.document, same(document));
        await show(downloading.copyWith(pendingTrackId: null));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(LyricView), findsNothing);
        expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
        expect(controller.document, isNull);
        await show(discovering);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await show(PlayerSubtitleState(stableId: _item.stableId));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${variant.name} ignores stale subtitles and keeps failures actionable',
      (tester) async {
        await _pumpPanel(
          tester,
          variant: variant,
          item: _item.copyWith(kind: CollectionKind.spoken),
        );
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(PlayerLyricPanel)),
        );
        _NoSubtitles subtitles =
            container.read(playerSubtitleControllerProvider.notifier)
                as _NoSubtitles;
        Future<void> show(PlayerSubtitleState state) async {
          subtitles.setSubtitles(state);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }

        for (final PlayerSubtitleState stale in <PlayerSubtitleState>[
          const PlayerSubtitleState(
            stableId: 'previous',
            isDiscovering: true,
            pendingTrackId: 'old-track',
          ),
          const PlayerSubtitleState(
            stableId: 'previous',
            errorMessage: '上一首字幕失败',
          ),
          _AiSubtitles().build().copyWith(stableId: 'previous'),
        ]) {
          await show(stale);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.byType(LyricView), findsNothing);
          expect(find.text('上一首字幕失败'), findsNothing);
          expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
        }
        await show(
          PlayerSubtitleState(
            stableId: _item.stableId,
            errorMessage: '字幕列表获取失败',
          ),
        );
        expect(find.text('字幕列表获取失败'), findsOneWidget);
        expect(find.text('重试'), findsOneWidget);
        expect(find.text('当前视频没有可用歌词|字幕'), findsNothing);
        await tester.tap(find.text('重试'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('字幕列表获取失败'), findsNothing);
        expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
        subtitles =
            container.read(playerSubtitleControllerProvider.notifier)
                as _NoSubtitles;
        await show(
          PlayerSubtitleState(
            stableId: _item.stableId,
            tracks: const <BiliSubtitleTrack>[_subtitleTrack],
            errorMessage: '字幕加载失败，请重试',
          ),
        );
        expect(find.text('字幕加载失败，请重试'), findsOneWidget);
        expect(find.text('选择字幕'), findsOneWidget);
        expect(find.text('当前视频没有可用歌词|字幕'), findsNothing);
        await show(
          _AiSubtitles().build().copyWith(
            tracks: const <BiliSubtitleTrack>[_subtitleTrack],
            errorMessage: '字幕加载失败，请重试',
          ),
        );
        expect(find.byType(LyricView), findsOneWidget);
        expect(find.text('字幕加载失败，请重试（选择字幕）'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('${variant.name} music absence preserves lyric errors', (
      tester,
    ) async {
      await _pumpPanel(tester, variant: variant);
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(PlayerLyricPanel)),
      );
      final _MetadataController metadata =
          container.read(metadataControllerProvider.notifier)
              as _MetadataController;
      metadata.clearLyrics();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
      metadata.failLyrics();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('歌词查询失败'), findsOneWidget);
      expect(find.text('歌词服务暂时不可用'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      expect(find.text('当前视频没有可用歌词|字幕'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'visible playback advances every frame without rebuilding lyrics',
    (tester) async {
      await _pumpPanel(tester, isPlaying: true);
      final LyricView view = tester.widget<LyricView>(find.byType(LyricView));
      final LyricController controller = view.controller;
      final Duration start = controller.position;
      expect(controller.isAdvancing, isTrue);
      for (int frame = 1; frame <= 3; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(controller.position, start + Duration(milliseconds: 16 * frame));
        expect(tester.widget<LyricView>(find.byType(LyricView)), same(view));
      }
    },
  );

  testWidgets(
    'AI subtitle progress and offset rebuilds preserve the document',
    (tester) async {
      await _pumpPanel(tester, useAiSubtitles: true);
      final LyricController controller = tester
          .widget<LyricView>(find.byType(LyricView))
          .controller;
      final LyricDocument document = controller.document!;
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(PlayerLyricPanel)),
      );
      final _AiSubtitles subtitles =
          container.read(playerSubtitleControllerProvider.notifier)
              as _AiSubtitles;
      final PlayerSubtitleState initial = container.read(
        playerSubtitleControllerProvider,
      );
      final List<LyricLine> lines = document.lines
          .where((line) => line.text.isNotEmpty)
          .toList();
      expect(lines, hasLength(initial.lines.length));
      for (int index = 0; index < lines.length; index++) {
        expect(
          lines[index].start,
          Duration(milliseconds: initial.lines[index].startMs),
        );
        expect(
          lines[index].end,
          Duration(milliseconds: initial.lines[index].endMs),
        );
        expect(lines[index].text, initial.lines[index].text);
      }
      expect(document.lines.every((line) => line.words == null), isTrue);
      for (final int positionMs in <int>[2016, 2032, 2048]) {
        await _pumpPanel(
          tester,
          useAiSubtitles: true,
          position: Duration(milliseconds: positionMs),
          settleDuration: Duration.zero,
        );
        expect(
          tester.widget<LyricView>(find.byType(LyricView)).controller,
          same(controller),
        );
        expect(controller.document, same(document));
        expect(controller.position, Duration(milliseconds: positionMs));
      }
      subtitles.setOffset(175);
      await tester.pump();
      expect(controller.document, same(document));
      expect(controller.timeOffset, const Duration(milliseconds: 175));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('hidden lyrics sync snapshots without advancing between frames', (
    tester,
  ) async {
    await _pumpPanel(tester, isPlaying: true);
    final LyricController controller = tester
        .widget<LyricView>(find.byType(LyricView))
        .controller;
    await _pumpPanel(
      tester,
      isPlaying: true,
      isActive: false,
      position: const Duration(seconds: 5),
    );
    expect(controller.isAdvancing, isFalse);
    expect(controller.position, const Duration(seconds: 5));
    expect(
      TickerMode.valuesOf(tester.element(find.byType(LyricView))).enabled,
      isFalse,
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.position, const Duration(seconds: 5));
    await _pumpPanel(
      tester,
      isPlaying: true,
      isActive: false,
      position: const Duration(milliseconds: 5250),
      settleDuration: Duration.zero,
    );
    expect(controller.position, const Duration(milliseconds: 5250));
    await _pumpPanel(
      tester,
      isPlaying: true,
      position: const Duration(seconds: 6),
      settleDuration: Duration.zero,
    );
    expect(controller.isAdvancing, isTrue);
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.position, const Duration(milliseconds: 6016));
  });

  testWidgets('pause buffering speed and seek preserve the lyric clock', (
    tester,
  ) async {
    await _pumpPanel(tester, isPlaying: true, speed: 2);
    final LyricController controller = tester
        .widget<LyricView>(find.byType(LyricView))
        .controller;
    final Duration start = controller.position;
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.position, start + const Duration(milliseconds: 32));
    for (final bool buffering in <bool>[false, true]) {
      await _pumpPanel(
        tester,
        isPlaying: buffering,
        isBuffering: buffering,
        position: controller.position,
        settleDuration: Duration.zero,
      );
      final Duration stopped = controller.position;
      expect(controller.isAdvancing, isFalse);
      await tester.pump(const Duration(milliseconds: 80));
      expect(controller.position, stopped);
    }
    await _pumpPanel(
      tester,
      position: const Duration(seconds: 1),
      settleDuration: Duration.zero,
    );
    expect(controller.position, const Duration(seconds: 1));
    await _pumpPanel(
      tester,
      isPlaying: true,
      position: const Duration(seconds: 14),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.position, const Duration(seconds: 15));
  });

  testWidgets('ordinary progress rebuilds preserve an in-flight scroll', (
    tester,
  ) async {
    await _pumpPanel(tester);
    final LyricPreset preset = tester
        .widget<LyricView>(find.byType(LyricView))
        .preset!;
    await _pumpPanel(
      tester,
      position: const Duration(seconds: 5),
      settleDuration: Duration.zero,
    );
    final ScrollableState scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(LyricView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final double before = scrollable.position.pixels;
    await _pumpPanel(
      tester,
      position: const Duration(seconds: 5),
      settleDuration: Duration.zero,
    );
    expect(tester.widget<LyricView>(find.byType(LyricView)).preset, preset);
    expect(scrollable.position.pixels, closeTo(before, 0.001));
    await tester.pump(const Duration(milliseconds: 600));
    expect(scrollable.position.pixels, greaterThan(before));
  });

  testWidgets('lyric page uses live progress only while visible', (
    tester,
  ) async {
    final ValueNotifier<bool> active = ValueNotifier(true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataControllerProvider.overrideWith(_MetadataController.new),
          playerSubtitleControllerProvider.overrideWith(_NoSubtitles.new),
          playerLyricSettingsLogicProvider.overrideWith(
            _LyricSettingsLogic.new,
          ),
          playerControllerProvider.overrideWith(_PlayerController.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: active,
              builder: (context, isActive, _) => PlayerLyricPage(
                state: const PlayerState(isReady: true),
                item: _item,
                isActive: isActive,
                onSeek: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(PlayerLyricPage)),
    );
    final _PlayerController player =
        container.read(playerControllerProvider.notifier) as _PlayerController;
    final LyricController controller = tester
        .widget<LyricView>(find.byType(LyricView))
        .controller;
    player.setPosition(const Duration(milliseconds: 2016));
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.position, const Duration(milliseconds: 2016));
    active.value = false;
    await tester.pump();
    player.setPosition(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 249));
    expect(controller.position, const Duration(milliseconds: 2016));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(controller.position, const Duration(seconds: 3));
    active.value = true;
    player.setPosition(const Duration(milliseconds: 3016));
    await tester.pump();
    expect(controller.position, const Duration(milliseconds: 3016));
    expect(
      container.read(playerProgressProvider).asData!.value.position,
      const Duration(seconds: 3),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    active.dispose();
  });

  for (final PlayerLyricPanelVariant variant
      in PlayerLyricPanelVariant.values) {
    testWidgets(
      '${variant.name} applies saved appearance without reloading lyrics',
      (tester) async {
        await _pumpPanel(tester, variant: variant);
        final LyricView initial = tester.widget<LyricView>(
          find.byType(LyricView),
        );
        final LyricController controller = initial.controller;
        final LyricDocument document = controller.document!;
        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(PlayerLyricPanel)),
        );
        final PlayerLyricSettingsLogic settings = container.read(
          playerLyricSettingsLogicProvider.notifier,
        );
        await settings.update(
          const PlayerLyricSettings(
            fontScale: 1.5,
            lineSpacing: 40,
            alignment: PlayerLyricAlignment.center,
            colorMode: PlayerLyricColorMode.custom,
            customColor: 0xff123456,
            motion: PlayerLyricMotion.reduced,
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        final LyricPreset preset = tester
            .widget<LyricView>(find.byType(LyricView))
            .preset!;
        expect(preset.textStyle.fontSize, 45);
        expect(preset.translationTextStyle.fontSize, 24);
        expect(preset.lineSpacing, 40);
        expect(preset.textAlign, TextAlign.center);
        expect(preset.contentAlignment, LyricContentAlignment.center);
        expect(preset.highlight.color, const Color(0xff123456));
        expect(
          preset.activeTranslationTextStyle.color,
          const Color(0xff123456),
        );
        expect(preset.countdown.color, const Color(0xff123456));
        expect(preset.countdown.breathDuration, Duration.zero);
        expect(preset.wordEffects.floatAmplitude, 0);
        expect(preset.lineMotion.maxLag, 0);
        expect(preset.distanceBlur.maxSigma, 0);
        expect(controller.document, same(document));
        expect(controller.position, const Duration(seconds: 2));
        await settings.update(
          container
              .read(playerLyricSettingsLogicProvider)
              .copyWith(
                activeFontSize: 52,
                activeFontWeight: 800,
                textOpacity: 0.4,
                activeTextOpacity: 0.9,
                activeTextColor: 0xffabcdef,
                translationFontSize: 18,
                activeTranslationFontSize: 22,
                translationSpacing: 12,
                contentAlignment: PlayerLyricAlignment.end,
                displayMode: PlayerLyricDisplayMode.activeLine,
                layoutMode: PlayerLyricLayoutMode.dualStyle,
                horizontalPadding: 36,
                activeAnchorUnit: PlayerLyricAnchorUnit.pixels,
                activeAnchorPosition: 120,
                activeAnchorTarget: PlayerLyricAnchorTarget.lineCenter,
                selectionAnchorPosition: 0.6,
                selectionAnchorTarget: PlayerLyricAnchorTarget.translationText,
              ),
        );
        await tester.pump(const Duration(seconds: 1));
        final LyricView updated = tester.widget<LyricView>(
          find.byType(LyricView),
        );
        expect(updated.controller, same(controller));
        expect(controller.document, same(document));
        expect(updated.preset!.activeTextStyle.fontSize, 52);
        expect(updated.preset!.activeTextStyle.fontWeight, FontWeight.w800);
        expect(updated.preset!.activeTextStyle.color!.a, closeTo(0.9, 0.01));
        expect(updated.preset!.translationTextStyle.fontSize, 18);
        expect(updated.preset!.activeTranslationTextStyle.fontSize, 22);
        expect(updated.preset!.translationSpacing, 12);
        expect(updated.preset!.textAlign, TextAlign.center);
        expect(updated.preset!.contentAlignment, LyricContentAlignment.end);
        expect(updated.preset!.displayMode, LyricDisplayMode.activeLine);
        expect(updated.preset!.layoutMode, LyricLayoutMode.dualStyle);
        expect(
          updated.preset!.padding,
          const EdgeInsets.symmetric(horizontal: 36),
        );
        expect(
          updated.preset!.activeAnchor,
          const LyricAnchor.pixels(120, target: LyricAnchorTarget.lineCenter),
        );
        expect(
          updated.preset!.selectionAnchor,
          const LyricAnchor.fraction(
            0.6,
            target: LyricAnchorTarget.translationText,
          ),
        );
        await settings.setShowTranslation(false);
        await tester.pump(const Duration(seconds: 1));
        expect(controller.document!.lines.first.translation, isNull);
        expect(
          tester.widget<LyricView>(find.byType(LyricView)).controller,
          same(controller),
        );
        await settings.reset();
        await tester.pump(const Duration(seconds: 1));
        expect(controller.document!.lines.first.translation, '翻译一');
        expect(
          tester
              .widget<LyricView>(find.byType(LyricView))
              .preset!
              .textStyle
              .fontSize,
          30,
        );
      },
    );
  }
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
        base.textStyle.copyWith(fontSize: 30),
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
    expect(find.text('当前视频没有可用歌词|字幕'), findsOneWidget);
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  PlayerLyricPanelVariant variant = PlayerLyricPanelVariant.mobile,
  PlayableItem item = _item,
  Duration position = const Duration(seconds: 2),
  bool showTranslation = true,
  bool useAiSubtitles = false,
  bool isActive = true,
  bool isPlaying = false,
  bool isBuffering = false,
  double speed = 1,
  Duration settleDuration = const Duration(seconds: 1),
  Color? activeColor,
  Brightness brightness = Brightness.light,
  ValueChanged<Duration>? onSeek,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataControllerProvider.overrideWith(_MetadataController.new),
        playerSubtitleControllerProvider.overrideWith(
          useAiSubtitles ? _AiSubtitles.new : _NoSubtitles.new,
        ),
        playerLyricSettingsLogicProvider.overrideWith(_LyricSettingsLogic.new),
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
                      isReady: true,
                      isPlaying: isPlaying,
                      isBuffering: isBuffering,
                      speed: speed,
                    ),
                    item: item,
                    isActive: isActive,
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
  await tester.pump(settleDuration);
}

class _AiSubtitles extends PlayerSubtitleController {
  @override
  PlayerSubtitleState build() => PlayerSubtitleState(
    stableId: _item.stableId,
    selectedTrackId: 'ai-zh',
    lines: const <BiliSubtitleLine>[
      BiliSubtitleLine(startMs: 1250, endMs: 2575, text: 'AI字幕第一行'),
      BiliSubtitleLine(startMs: 4000, endMs: 6123, text: 'AI字幕第二行'),
    ],
  );

  void setOffset(int offsetMs) => state = state.copyWith(offsetMs: offsetMs);
}

class _NoSubtitles extends PlayerSubtitleController {
  @override
  PlayerSubtitleState build() => const PlayerSubtitleState();

  void setSubtitles(PlayerSubtitleState value) => state = value;
}

class _PlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    position: Duration(seconds: 2),
    duration: Duration(seconds: 15),
    isReady: true,
  );

  void setPosition(Duration position) =>
      state = state.copyWith(position: position);
}

class _LyricSettingsLogic extends PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() => const PlayerLyricSettings();

  @override
  Future<void> update(PlayerLyricSettings value) async => state = value;
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

  void failLyrics() => state = MetadataState(
    stableId: _item.stableId,
    errorMessage: '歌词服务暂时不可用',
  );
}
