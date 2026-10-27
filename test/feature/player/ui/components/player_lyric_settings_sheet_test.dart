import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens on text tab with fixed translated preview and no switch', (
    WidgetTester tester,
  ) async {
    final _SettingsLogic logic = _SettingsLogic(
      initial: const PlayerLyricSettings(showTranslation: false),
    );
    final ProviderContainer container = await _pumpHost(tester, logic);
    await _open(tester);

    expect(PlatformUtil.isDesktop, isTrue);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('歌词外观'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('文字'), findsOneWidget);
    expect(find.text('布局'), findsOneWidget);
    expect(find.text('配色与动效'), findsOneWidget);
    expect(find.textContaining('预设'), findsNothing);
    expect(find.textContaining('Apple Music'), findsNothing);
    expect(find.text('显示译文'), findsNothing);
    expect(find.textContaining('正文大小'), findsNothing);
    expect(find.byKey(const Key('lyricFontScale')), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(_preview(tester).preset!.interactive, isFalse);
    expect(
      _preview(tester).controller.document!.lines.first.translation,
      'Hear the colors of music',
    );

    final Rect previewBounds = tester.getRect(find.byType(LyricView));
    final LyricController previewController = _preview(tester).controller;
    for (final (String key, double value) in <(String, double)>[
      ('lyricActiveFontSize', 30),
      ('lyricTextOpacity', 0.6),
      ('lyricActiveTextOpacity', 0.6),
      ('lyricTranslationFontSize', 16),
      ('lyricActiveTranslationFontSize', 16),
      ('lyricTranslationSpacing', 8),
    ]) {
      await _reveal(tester, find.byKey(Key(key)));
      expect(_slider(tester, key).value, value);
    }
    expect(tester.getRect(find.byType(LyricView)), previewBounds);
    expect(_preview(tester).controller, same(previewController));
    await _reveal(tester, find.byKey(const Key('lyricActiveFontWeight')));
    final DropdownButton<int> weight = tester.widget(
      find.byKey(const Key('lyricActiveFontWeight')),
    );
    expect(weight.items!.map((DropdownMenuItem<int> item) => item.value), <int>[
      400,
      500,
      600,
      700,
      800,
    ]);
    expect(
      weight.items!.map(
        (DropdownMenuItem<int> item) => (item.child as Text).data,
      ),
      <String>['常规 400', '中等 500', '半粗 600', '加粗 700', '特粗 800'],
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).showTranslation,
      isFalse,
    );
    expect(logic.updates, isEmpty);
  });

  testWidgets('previews typography drafts and automatically saves on release', (
    WidgetTester tester,
  ) async {
    final _SettingsLogic logic = _SettingsLogic(
      initial: const PlayerLyricSettings(fontScale: 1.3),
    );
    final ProviderContainer container = await _pumpHost(tester, logic);
    await _open(tester);

    expect(_preview(tester).preset!.textStyle.fontSize, 39);
    expect(_activeTextStyle(tester).fontSize, 39);
    expect(_slider(tester, 'lyricActiveFontSize').value, 39);
    expect(logic.updates, isEmpty);

    final List<
      (
        String,
        double,
        double Function(PlayerLyricSettings),
        double Function(LyricPreset),
      )
    >
    edits =
        <
          (
            String,
            double,
            double Function(PlayerLyricSettings),
            double Function(LyricPreset),
          )
        >[
          (
            'lyricActiveFontSize',
            44,
            (PlayerLyricSettings value) => value.activeFontSize!,
            (LyricPreset value) => value.activeTextStyle.fontSize!,
          ),
          (
            'lyricTextOpacity',
            0.4,
            (PlayerLyricSettings value) => value.textOpacity,
            (LyricPreset value) => value.textStyle.color!.a,
          ),
          (
            'lyricActiveTextOpacity',
            0.8,
            (PlayerLyricSettings value) => value.activeTextOpacity!,
            (LyricPreset value) => value.activeTextStyle.color!.a,
          ),
          (
            'lyricTranslationFontSize',
            20,
            (PlayerLyricSettings value) => value.translationFontSize!,
            (LyricPreset value) => value.translationTextStyle.fontSize!,
          ),
          (
            'lyricActiveTranslationFontSize',
            24,
            (PlayerLyricSettings value) => value.activeTranslationFontSize!,
            (LyricPreset value) => value.activeTranslationTextStyle.fontSize!,
          ),
          (
            'lyricTranslationSpacing',
            12,
            (PlayerLyricSettings value) => value.translationSpacing,
            (LyricPreset value) => value.translationSpacing,
          ),
        ];
    for (final (key, value, storedValue, previewValue) in edits) {
      await _reveal(tester, find.byKey(Key(key)));
      final PlayerLyricSettings before = container.read(
        playerLyricSettingsLogicProvider,
      );
      final int saveCount = logic.updates.length;
      _slider(tester, key).onChanged!(value);
      await tester.pump();
      expect(previewValue(_preview(tester).preset!), closeTo(value, 1 / 255));
      expect(container.read(playerLyricSettingsLogicProvider), before);
      expect(logic.updates, hasLength(saveCount));
      _slider(tester, key).onChangeEnd!(value);
      await tester.pump();
      expect(
        storedValue(container.read(playerLyricSettingsLogicProvider)),
        value,
      );
      expect(logic.updates, hasLength(saveCount + 1));
    }

    await _choose(
      tester,
      find.byKey(const Key('lyricActiveFontWeight')),
      '特粗 800',
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).activeFontWeight,
      800,
    );
    expect(_activeTextStyle(tester).fontWeight, FontWeight.w800);

    final PlayerLyricSettings saved = container.read(
      playerLyricSettingsLogicProvider,
    );
    expect(saved.fontScale, 1.3);
    final LyricPreset savedPreview = _preview(tester).preset!;
    await _close(tester);
    await _open(tester);
    expect(container.read(playerLyricSettingsLogicProvider), saved);
    expect(find.text('当前句大小 · 44 px'), findsOneWidget);
    expect(_preview(tester).preset!, savedPreview);
    for (final (key, value, _, _) in edits) {
      await _reveal(tester, find.byKey(Key(key)));
      expect(_slider(tester, key).value, value);
    }
  });

  testWidgets(
    'supports optional active text color independently of highlight',
    (WidgetTester tester) async {
      final _SettingsLogic logic = _SettingsLogic();
      final ProviderContainer container = await _pumpHost(tester, logic);
      await _open(tester);
      final Color? highlight = _preview(tester).preset!.highlight.color;

      await _choose(
        tester,
        find.byKey(const Key('lyricActiveTextColorMode')),
        '自定义',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).activeTextColor,
        isNotNull,
      );
      await _reveal(tester, find.byType(TextFormField));
      await tester.enterText(find.byType(TextFormField), '#12ab34');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        container.read(playerLyricSettingsLogicProvider).activeTextColor,
        0xff12ab34,
      );
      expect(_activeTextStyle(tester).color!.toARGB32() & 0x00ffffff, 0x12ab34);
      expect(_preview(tester).preset!.highlight.color, highlight);

      await _choose(
        tester,
        find.byKey(const Key('lyricActiveTextColorMode')),
        '跟随主题',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).activeTextColor,
        isNull,
      );
      expect(find.byType(TextFormField), findsNothing);
    },
  );

  testWidgets('saves independent layout, wrapping, padding and both anchors', (
    WidgetTester tester,
  ) async {
    final _SettingsLogic logic = _SettingsLogic();
    final ProviderContainer container = await _pumpHost(tester, logic);
    await _open(tester);
    final Rect previewBounds = tester.getRect(find.byType(LyricView));
    await _tap(tester, find.text('布局'));

    await _choose(tester, find.byKey(const Key('lyricDisplayMode')), '仅当前句');
    expect(
      container.read(playerLyricSettingsLogicProvider).displayMode,
      PlayerLyricDisplayMode.activeLine,
    );
    expect(_preview(tester).preset!.displayMode, LyricDisplayMode.activeLine);
    await _choose(tester, find.byKey(const Key('lyricLayoutMode')), '随字号重新换行');
    expect(
      container.read(playerLyricSettingsLogicProvider).layoutMode,
      PlayerLyricLayoutMode.dualStyle,
    );
    expect(_preview(tester).preset!.layoutMode, LyricLayoutMode.dualStyle);
    await _choose(tester, find.byKey(const Key('lyricAlignment')), '居中');
    expect(_preview(tester).preset!.textAlign, TextAlign.center);
    expect(
      _preview(tester).preset!.contentAlignment,
      LyricContentAlignment.start,
    );
    await _choose(
      tester,
      find.byKey(const Key('lyricContentAlignment')),
      '右对齐',
    );
    await _choose(tester, find.byKey(const Key('lyricAlignment')), '左对齐');
    expect(
      container.read(playerLyricSettingsLogicProvider).alignment,
      PlayerLyricAlignment.start,
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).contentAlignment,
      PlayerLyricAlignment.end,
    );
    expect(_preview(tester).preset!.textAlign, TextAlign.start);
    expect(
      _preview(tester).preset!.contentAlignment,
      LyricContentAlignment.end,
    );

    await _changeSlider(tester, 'lyricLineSpacing', 36);
    await _changeSlider(tester, 'lyricHorizontalPadding', 40);
    expect(container.read(playerLyricSettingsLogicProvider).lineSpacing, 36);
    expect(
      container.read(playerLyricSettingsLogicProvider).horizontalPadding,
      40,
    );
    expect(_preview(tester).preset!.lineSpacing, 36);
    expect(
      _preview(tester).preset!.padding.resolve(TextDirection.ltr).horizontal,
      80,
    );

    await _choose(
      tester,
      find.byKey(const Key('lyricActiveAnchorUnit')),
      '距顶部像素',
    );
    await _changeSlider(tester, 'lyricActiveAnchorPosition', 120);
    await _choose(
      tester,
      find.byKey(const Key('lyricActiveAnchorTarget')),
      '译文中心',
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).activeAnchorUnit,
      PlayerLyricAnchorUnit.pixels,
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).activeAnchorTarget,
      PlayerLyricAnchorTarget.translationText,
    );
    expect(
      _preview(tester).preset!.activeAnchor,
      const LyricAnchor.pixels(120, target: LyricAnchorTarget.translationText),
    );

    await _choose(
      tester,
      find.byKey(const Key('lyricSelectionAnchorUnit')),
      '距顶部像素',
    );
    await _changeSlider(tester, 'lyricSelectionAnchorPosition', 180);
    await _choose(
      tester,
      find.byKey(const Key('lyricSelectionAnchorTarget')),
      '含译文的整体中心',
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).selectionAnchorUnit,
      PlayerLyricAnchorUnit.pixels,
    );
    expect(
      container.read(playerLyricSettingsLogicProvider).selectionAnchorTarget,
      PlayerLyricAnchorTarget.lineCenter,
    );
    expect(
      _preview(tester).preset!.selectionAnchor,
      const LyricAnchor.pixels(180, target: LyricAnchorTarget.lineCenter),
    );

    await _choose(
      tester,
      find.byKey(const Key('lyricActiveAnchorUnit')),
      '按区域高度',
    );
    await _changeSlider(tester, 'lyricActiveAnchorPosition', 0.6);
    await _choose(
      tester,
      find.byKey(const Key('lyricActiveAnchorTarget')),
      '正文中心',
    );
    await _choose(
      tester,
      find.byKey(const Key('lyricSelectionAnchorUnit')),
      '按区域高度',
    );
    await _changeSlider(tester, 'lyricSelectionAnchorPosition', 0.7);
    await _choose(
      tester,
      find.byKey(const Key('lyricSelectionAnchorTarget')),
      '译文中心',
    );
    expect(
      _preview(tester).preset!.activeAnchor,
      const LyricAnchor.fraction(0.6, target: LyricAnchorTarget.mainText),
    );
    expect(
      _preview(tester).preset!.selectionAnchor,
      const LyricAnchor.fraction(
        0.7,
        target: LyricAnchorTarget.translationText,
      ),
    );
    expect(tester.getRect(find.byType(LyricView)), previewBounds);
    expect(find.text('显示译文'), findsNothing);

    final PlayerLyricSettings saved = container.read(
      playerLyricSettingsLogicProvider,
    );
    final LyricPreset savedPreview = _preview(tester).preset!;
    await _close(tester);
    await _open(tester);
    expect(container.read(playerLyricSettingsLogicProvider), saved);
    expect(_preview(tester).preset!, savedPreview);
    await _tap(tester, find.text('布局'));
    for (final (String key, double value) in <(String, double)>[
      ('lyricLineSpacing', 36),
      ('lyricHorizontalPadding', 40),
      ('lyricActiveAnchorPosition', 0.6),
      ('lyricSelectionAnchorPosition', 0.7),
    ]) {
      await _reveal(tester, find.byKey(Key(key)));
      expect(_slider(tester, key).value, value);
    }
    await _choose(tester, find.byKey(const Key('lyricDisplayMode')), '多行列表');
    await _choose(tester, find.byKey(const Key('lyricLayoutMode')), '保持换行位置');
    expect(_preview(tester).preset!.displayMode, LyricDisplayMode.scrollable);
    expect(_preview(tester).preset!.layoutMode, LyricLayoutMode.fixed);
  });

  testWidgets(
    'validates hex colors and applies color and motion in their tab',
    (WidgetTester tester) async {
      final _SettingsLogic logic = _SettingsLogic();
      final ProviderContainer container = await _pumpHost(tester, logic);
      await _open(tester);
      await _tap(tester, find.text('配色与动效'));
      await _choose(
        tester,
        find.byType(DropdownButton<PlayerLyricColorMode>),
        '自定义颜色',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).colorMode,
        PlayerLyricColorMode.custom,
      );

      await _reveal(tester, find.byType(TextFormField));
      await tester.enterText(find.byType(TextFormField), '#GG0000');
      await _tap(tester, find.byTooltip('应用颜色'));
      expect(find.text('请输入六位十六进制颜色，如 #E91E63'), findsOneWidget);
      expect(logic.updates, hasLength(1));
      expect(
        container.read(playerLyricSettingsLogicProvider).customColor,
        const PlayerLyricSettings().customColor,
      );

      await tester.enterText(find.byType(TextFormField), '#12ab34');
      await _tap(tester, find.byTooltip('应用颜色'));
      expect(find.text('请输入六位十六进制颜色，如 #E91E63'), findsNothing);
      expect(
        container.read(playerLyricSettingsLogicProvider).customColor,
        0xff12ab34,
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '#12AB34',
      );
      expect(_preview(tester).preset!.highlight.color, const Color(0xff12ab34));
      expect(
        _activeTranslationTextStyle(tester).color,
        const Color(0xff12ab34),
      );
      expect(find.text('显示译文'), findsNothing);

      await _choose(
        tester,
        find.byType(DropdownButton<PlayerLyricMotion>),
        '减弱（仅平滑滚动）',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).motion,
        PlayerLyricMotion.reduced,
      );
      expect(
        _preview(tester).preset!.scrollAnimation,
        const LyricScrollAnimation.fixed(duration: Duration(milliseconds: 240)),
      );
      expect(
        _preview(tester).preset!.lineTransition,
        const LyricLineTransition.none(),
      );

      await _choose(
        tester,
        find.byType(DropdownButton<PlayerLyricMotion>),
        '关闭',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).motion,
        PlayerLyricMotion.off,
      );
      expect(
        _preview(tester).preset!.scrollAnimation,
        const LyricScrollAnimation.none(),
      );
      expect(_preview(tester).preset!.countdown, const LyricCountdown.none());

      await _choose(
        tester,
        find.byType(DropdownButton<PlayerLyricMotion>),
        '完整（当前效果）',
      );
      expect(
        container.read(playerLyricSettingsLogicProvider).motion,
        PlayerLyricMotion.full,
      );
      expect(
        _preview(tester).preset!.lineMotion,
        LyricPresets.appleMusic.lineMotion,
      );
    },
  );

  testWidgets(
    'restores saved fields across all tabs and keeps reset on reopen',
    (WidgetTester tester) async {
      const PlayerLyricSettings saved = PlayerLyricSettings(
        fontScale: 1.4,
        activeFontSize: 48,
        activeFontWeight: 800,
        textOpacity: 0.4,
        activeTextOpacity: 0.8,
        activeTextColor: 0xffabcdef,
        translationFontSize: 22,
        activeTranslationFontSize: 26,
        translationSpacing: 14,
        lineSpacing: 40,
        alignment: PlayerLyricAlignment.end,
        contentAlignment: PlayerLyricAlignment.center,
        displayMode: PlayerLyricDisplayMode.activeLine,
        layoutMode: PlayerLyricLayoutMode.dualStyle,
        horizontalPadding: 36,
        activeAnchorUnit: PlayerLyricAnchorUnit.pixels,
        activeAnchorPosition: 120,
        activeAnchorTarget: PlayerLyricAnchorTarget.translationText,
        selectionAnchorUnit: PlayerLyricAnchorUnit.pixels,
        selectionAnchorPosition: 180,
        selectionAnchorTarget: PlayerLyricAnchorTarget.lineCenter,
        showTranslation: false,
        colorMode: PlayerLyricColorMode.custom,
        customColor: 0xff123456,
        motion: PlayerLyricMotion.off,
      );
      final _SettingsLogic logic = _SettingsLogic(initial: saved);
      final ProviderContainer container = await _pumpHost(tester, logic);
      await _open(tester);
      expect(_preview(tester).preset!.textStyle.fontSize, 42);
      expect(_activeTextStyle(tester).fontSize, 48);
      expect(_preview(tester).preset!.translationTextStyle.fontSize, 22);
      expect(_activeTranslationTextStyle(tester).fontSize, 26);
      expect(_preview(tester).preset!.textAlign, TextAlign.end);
      expect(
        _preview(tester).preset!.contentAlignment,
        LyricContentAlignment.center,
      );
      expect(_preview(tester).preset!.highlight.color, const Color(0xff123456));
      expect(
        _preview(tester).controller.document!.lines.first.translation,
        'Hear the colors of music',
      );
      expect(
        _preview(tester).preset!.scrollAnimation,
        const LyricScrollAnimation.none(),
      );

      await _tap(tester, find.text('配色与动效'));
      await _tap(tester, find.text('恢复默认'));
      expect(
        container.read(playerLyricSettingsLogicProvider),
        const PlayerLyricSettings(),
      );
      expect(logic.updates.single, const PlayerLyricSettings());
      expect(find.byType(TextFormField), findsNothing);
      expect(_preview(tester).preset!.textStyle.fontSize, 30);
      expect(_activeTextStyle(tester).fontSize, 30);
      expect(_preview(tester).preset!.translationTextStyle.fontSize, 16);
      expect(_activeTranslationTextStyle(tester).fontSize, 16);
      expect(_preview(tester).preset!.lineSpacing, 24);
      expect(_preview(tester).preset!.translationSpacing, 8);
      expect(_preview(tester).preset!.textAlign, TextAlign.start);
      expect(
        _preview(tester).preset!.contentAlignment,
        LyricContentAlignment.start,
      );
      expect(_preview(tester).preset!.displayMode, LyricDisplayMode.scrollable);
      expect(_preview(tester).preset!.layoutMode, LyricLayoutMode.fixed);
      expect(
        _preview(tester).preset!.activeAnchor,
        const LyricAnchor.fraction(0.38, target: LyricAnchorTarget.mainText),
      );
      expect(
        _preview(tester).preset!.lineMotion,
        LyricPresets.appleMusic.lineMotion,
      );
      await _tap(tester, find.text('文字'));
      await _reveal(tester, find.byKey(const Key('lyricActiveFontSize')));
      expect(_slider(tester, 'lyricActiveFontSize').value, 30);
      await _tap(tester, find.text('布局'));
      await _reveal(tester, find.byKey(const Key('lyricHorizontalPadding')));
      expect(_slider(tester, 'lyricHorizontalPadding').value, 24);

      await _close(tester);
      await _open(tester);
      expect(
        container.read(playerLyricSettingsLogicProvider),
        const PlayerLyricSettings(),
      );
      expect(_slider(tester, 'lyricActiveFontSize').value, 30);
      expect(_preview(tester).preset!.textAlign, TextAlign.start);
    },
  );

  testWidgets('failed saves roll back slider, dropdown and reset drafts', (
    WidgetTester tester,
  ) async {
    const PlayerLyricSettings saved = PlayerLyricSettings(
      fontScale: 1.2,
      activeFontSize: 44,
      contentAlignment: PlayerLyricAlignment.end,
      showTranslation: false,
    );
    final _SettingsLogic logic = _SettingsLogic(initial: saved);
    final ProviderContainer container = await _pumpHost(tester, logic);
    await _open(tester);
    logic.failUpdates = true;

    _slider(tester, 'lyricActiveFontSize').onChanged!(50);
    await tester.pump();
    expect(_activeTextStyle(tester).fontSize, 50);
    _slider(tester, 'lyricActiveFontSize').onChangeEnd!(50);
    await tester.pump();
    expect(find.text('歌词外观保存失败，请重试'), findsOneWidget);
    expect(container.read(playerLyricSettingsLogicProvider), saved);
    expect(find.text('当前句大小 · 44 px'), findsOneWidget);
    expect(_preview(tester).preset!.textStyle.fontSize, 36);
    expect(_activeTextStyle(tester).fontSize, 44);
    expect(_slider(tester, 'lyricActiveFontSize').value, 44);

    await _choose(
      tester,
      find.byKey(const Key('lyricActiveFontWeight')),
      '常规 400',
    );
    expect(container.read(playerLyricSettingsLogicProvider), saved);
    expect(
      tester
          .widget<DropdownButton<int>>(
            find.byKey(const Key('lyricActiveFontWeight')),
          )
          .value,
      700,
    );
    expect(_activeTextStyle(tester).fontWeight, FontWeight.w700);
    expect(
      _preview(tester).controller.document!.lines.first.translation,
      'Hear the colors of music',
    );
    expect(find.text('显示译文'), findsNothing);
    await _tap(tester, find.text('恢复默认'));
    expect(container.read(playerLyricSettingsLogicProvider), saved);
    expect(_preview(tester).preset!.textStyle.fontSize, 36);
    expect(
      _preview(tester).preset!.contentAlignment,
      LyricContentAlignment.end,
    );

    logic.failUpdates = false;
    await _tap(tester, find.text('恢复默认'));
    expect(
      container.read(playerLyricSettingsLogicProvider),
      const PlayerLyricSettings(),
    );
    expect(_preview(tester).preset!.textStyle.fontSize, 30);
  });

  testWidgets('keeps preview and scrollable tabs usable on a narrow screen', (
    WidgetTester tester,
  ) async {
    await _pumpHost(tester, _SettingsLogic(), size: const Size(390, 740));
    await _open(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    final Rect previewBounds = tester.getRect(find.byType(LyricView));
    expect(previewBounds.left, greaterThanOrEqualTo(0));
    expect(previewBounds.right, lessThanOrEqualTo(390));
    expect(previewBounds.height, greaterThan(0));
    for (final (String tab, String control) in <(String, String)>[
      ('文字', 'lyricTranslationSpacing'),
      ('布局', 'lyricSelectionAnchorTarget'),
    ]) {
      await _tap(tester, find.text(tab));
      await _reveal(tester, find.byKey(Key(control)));
      expect(tester.getRect(find.byType(LyricView)), previewBounds);
      expect(tester.takeException(), isNull);
    }
    await _tap(tester, find.text('配色与动效'));
    await _choose(
      tester,
      find.byType(DropdownButton<PlayerLyricColorMode>),
      '自定义颜色',
    );
    await _reveal(tester, find.byType(TextFormField));
    expect(tester.getRect(find.byType(LyricView)), previewBounds);
    expect(tester.takeException(), isNull);
    await _close(tester);
  });
}

Future<ProviderContainer> _pumpHost(
  WidgetTester tester,
  _SettingsLogic logic, {
  Size size = const Size(1000, 1000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [playerLyricSettingsLogicProvider.overrideWith(() => logic)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () =>
                  showPlayerLyricSettings(context, activeColor: Colors.teal),
              child: const Text('打开歌词外观'),
            ),
          ),
        ),
      ),
    ),
  );
  final ProviderContainer container = ProviderScope.containerOf(
    tester.element(find.text('打开歌词外观')),
  );
  container.read(playerLyricSettingsLogicProvider);
  return container;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('打开歌词外观'));
  await tester.pump();
  // The preview floats continuously, so it never settles.
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _close(WidgetTester tester) async {
  await _tap(tester, find.byTooltip('关闭歌词外观'));
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(Dialog), findsNothing);
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final Finder scrollable = find
        .descendant(
          of: find.byType(TabBarView),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Scrollable &&
                axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
          ),
        )
        .first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(finder, 180, scrollable: scrollable);
  }
  await tester.ensureVisible(finder);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _choose(WidgetTester tester, Finder field, String label) async {
  await _tap(tester, field);
  await _tap(tester, find.text(label).last);
}

Future<void> _changeSlider(
  WidgetTester tester,
  String key,
  double value,
) async {
  await _reveal(tester, find.byKey(Key(key)));
  _slider(tester, key).onChanged!(value);
  await tester.pump();
  _slider(tester, key).onChangeEnd!(value);
  await tester.pump();
}

Slider _slider(WidgetTester tester, String key) =>
    tester.widget<Slider>(find.byKey(Key(key)));

LyricView _preview(WidgetTester tester) =>
    tester.widget<LyricView>(find.byType(LyricView));

TextStyle _activeTextStyle(WidgetTester tester) {
  final LyricPreset preset = _preview(tester).preset!;
  return preset.textStyle.merge(preset.activeTextStyle);
}

TextStyle _activeTranslationTextStyle(WidgetTester tester) {
  final LyricPreset preset = _preview(tester).preset!;
  return preset.translationTextStyle.merge(preset.activeTranslationTextStyle);
}

class _SettingsLogic extends PlayerLyricSettingsLogic {
  _SettingsLogic({this.initial = const PlayerLyricSettings()});

  final PlayerLyricSettings initial;
  bool failUpdates = false;
  final List<PlayerLyricSettings> updates = <PlayerLyricSettings>[];

  @override
  PlayerLyricSettings build() => initial;

  @override
  Future<void> update(PlayerLyricSettings value) async {
    updates.add(value);
    if (failUpdates) throw StateError('Save failed');
    state = value;
  }
}
