import 'dart:async';

import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/data/bili_subtitle_repository.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_subtitle_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  title: 'Song',
  author: 'Artist',
  coverUrl: '',
);
const _tracks = <BiliSubtitleTrack>[
  BiliSubtitleTrack(
    id: 'zh',
    language: 'zh-CN',
    label: '中文（自动生成）',
    url: 'https://example.com/zh',
  ),
  BiliSubtitleTrack(
    id: 'en',
    language: 'en',
    label: 'English（自动翻译）',
    url: 'https://example.com/en',
    isTranslated: true,
  ),
];
const _lines = <BiliSubtitleLine>[
  BiliSubtitleLine(startMs: 1250, endMs: 2575, text: '这是字幕第一行'),
  BiliSubtitleLine(
    startMs: 4000,
    endMs: 6123,
    text: 'This is a long subtitle line that wraps on a narrow screen',
  ),
];

void main() {
  test('subtitle gaps retain the previous line until the next starts', () {
    final controller = LyricController();
    addTearDown(controller.dispose);
    controller.loadDocument(buildSubtitleDocument(_lines));
    final active = <int?>[];
    controller.activeLineIndexListenable.addListener(
      () => active.add(controller.activeLineIndexListenable.value),
    );
    for (final (time, index) in <(int, int?)>[
      (1249, null),
      (1250, 0),
      (2574, 0),
      (2575, 0),
      (3999, 0),
      (4000, 1),
      (6123, 1),
      (60000, 1),
      (1500, 0),
      (0, null),
    ]) {
      controller.setPosition(Duration(milliseconds: time));
      expect(controller.activeLineIndex, index, reason: '$time ms');
    }
    expect(active, [0, 1, 0, null]);
    controller.setPosition(const Duration(milliseconds: 1500));
    expect(controller.document!.lines, hasLength(_lines.length));
    controller.timeOffset = const Duration(milliseconds: 1075);
    expect(controller.activeLineIndex, 0);
    expect(controller.activeLine?.text, _lines.first.text);
    expect(
      controller.document!.lines.first.end,
      const Duration(milliseconds: 2575),
    );
    controller.load('[00:01.250]Meting第一行\n[00:04.000]Meting第二行');
    expect(controller.activeLineIndex, 0);
  });

  testWidgets(
    'subtitle gap keeps scroll position instead of returning to top',
    (tester) async {
      final controller = LyricController();
      final lines = List.generate(
        30,
        (index) => BiliSubtitleLine(
          startMs: index * 3000,
          endMs: index * 3000 + 1000,
          text: '字幕第 $index 行',
        ),
      );
      controller.loadDocument(buildSubtitleDocument(lines));
      controller.setPosition(const Duration(milliseconds: 30500));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LyricView(
              controller: controller,
              preset: LyricPresets.appleMusic.copyWith(
                countdown: const LyricCountdown.none(),
                wordEffects: const LyricWordEffects(),
                scrollAnimation: const LyricScrollAnimation.none(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      final before = scroll.position.pixels;
      expect(before, greaterThan(scroll.position.minScrollExtent + 100));
      controller.setPosition(const Duration(milliseconds: 31500));
      await tester.pumpAndSettle();
      expect(controller.activeLineIndex, 10);
      expect(scroll.position.pixels, closeTo(before, 0.01));
      controller.setPosition(const Duration(milliseconds: 33000));
      await tester.pumpAndSettle();
      expect(controller.activeLineIndex, 11);
      expect(scroll.position.pixels, greaterThan(before));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets(
    'subtitle panel retains highlighting through gaps and after the last line',
    (tester) async {
      final fixture = await _pumpPage(tester, selectedTrackId: 'zh');
      LyricView view() => tester.widget<LyricView>(find.byType(LyricView));
      final controller = view().controller;
      final activeStyle = view().preset!.activeTextStyle;
      for (final (time, index) in [(3000, 0), (4000, 1), (14000, 1)]) {
        fixture.player.setPosition(Duration(milliseconds: time));
        await tester.pump();
        expect(controller.activeLineIndex, index);
        expect(view().preset!.activeTextStyle, activeStyle);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'subtitle button is hidden without tracks and shown after discovery',
    (tester) async {
      final fixture = await _pumpPage(tester, tracks: const []);
      expect(find.byTooltip('AI字幕'), findsNothing);
      fixture.subtitles.setValue(fixture.value.copyWith(tracks: _tracks));
      await tester.pump();
      expect(find.byTooltip('AI字幕'), findsOneWidget);
      fixture.subtitles.setValue(
        fixture.value.copyWith(stableId: 'stale-song'),
      );
      await tester.pump();
      expect(find.byTooltip('AI字幕'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final tracks in <List<BiliSubtitleTrack>>[const [], _tracks]) {
    for (final selectedTrackId in <String?>[null, 'zh']) {
      if (tracks.isEmpty && selectedTrackId != null) {
        continue;
      }
      testWidgets(
        'toolbar stays left aligned with fixed gaps and settings last '
        '(${tracks.length} tracks, $selectedTrackId)',
        (tester) async {
          await _pumpPage(
            tester,
            tracks: tracks,
            selectedTrackId: selectedTrackId,
          );
          final tooltips = <String>[
            '手动匹配歌词',
            '歌词偏移',
            if (selectedTrackId == null) '隐藏译文',
            if (tracks.isNotEmpty) 'AI字幕',
            '歌词外观',
          ];
          final rects = tooltips
              .map(
                (tooltip) => tester.getRect(
                  find.ancestor(
                    of: find.byTooltip(tooltip),
                    matching: find.byType(IconButton),
                  ),
                ),
              )
              .toList();
          if (tracks.isNotEmpty) {
            final subtitleButton = tester.widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.subtitles_outlined),
            );
            final searchButton = tester.widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.search_rounded),
            );
            expect(subtitleButton.onPressed, isNotNull);
            expect(subtitleButton.color, searchButton.color);
          }
          expect(rects.first.left, 12);
          for (int index = 1; index < rects.length; index++) {
            expect(rects[index].left - rects[index - 1].right, 20);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('320px toolbar keeps every control reachable with fixed gaps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpPage(tester);
    expect(find.byTooltip('AI字幕'), findsOneWidget);
    expect(find.byTooltip('隐藏译文'), findsOneWidget);
    final lyricView = tester.widget<LyricView>(find.byType(LyricView));
    expect(
      lyricView.controller.document!.lines.any(
        (line) => line.translation != null,
      ),
      isTrue,
    );
    final toolbar = find.ancestor(
      of: find.byTooltip('歌词外观'),
      matching: find.byType(SingleChildScrollView),
    );
    expect(toolbar, findsOneWidget);
    expect(
      tester
          .getRect(
            find.ancestor(
              of: find.byTooltip('手动匹配歌词'),
              matching: find.byType(IconButton),
            ),
          )
          .left,
      12,
    );
    await tester.drag(toolbar, const Offset(-200, 0));
    await tester.pump(const Duration(seconds: 1));
    for (final tooltip in ['隐藏译文', 'AI字幕', '歌词外观']) {
      final rect = tester.getRect(find.byTooltip(tooltip));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(find.byTooltip(tooltip).hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sheet switches to subtitles and back to Meting without losing translation',
    (tester) async {
      final fixture = await _pumpPage(tester);
      await _openSheet(tester);
      expect(find.text('Meting歌词'), findsOneWidget);
      expect(find.text(_tracks.first.label), findsOneWidget);
      expect(fixture.repository.loadedTracks, isEmpty);
      await tester.tap(find.text(_tracks.first.label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Meting歌词'), findsNothing);
      expect(fixture.value.selectedTrackId, 'zh');
      expect(fixture.repository.loadedTracks, ['zh']);
      expect(find.byTooltip('隐藏译文'), findsNothing);
      expect(find.byTooltip('显示译文'), findsNothing);
      expect(
        tester
            .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
            .showTranslation,
        isFalse,
      );
      final subtitles = tester
          .widget<LyricView>(find.byType(LyricView))
          .controller
          .document!;
      expect(
        subtitles.lines
            .where((line) => line.text.isNotEmpty)
            .map((line) => line.text),
        _lines.map((line) => line.text),
      );
      expect(subtitles.lines.every((line) => line.translation == null), isTrue);

      await _openSheet(tester);
      expect(_tile(tester, _tracks.first.label).selected, isTrue);
      await tester.tap(find.text('Meting歌词'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(fixture.value.usesSubtitles, isFalse);
      expect(find.byTooltip('隐藏译文'), findsOneWidget);
      final meting = tester
          .widget<LyricView>(find.byType(LyricView))
          .controller
          .document!;
      expect(meting.lines.first.text, 'Meting第一行');
      expect(meting.lines.first.translation, 'Translation one');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AI panel preserves line timestamps and disables simulated word timing',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final fixture = await _pumpPage(tester, selectedTrackId: 'zh');
      fixture.subtitles.adjustOffset(175);
      await tester.pump();
      final view = tester.widget<LyricView>(find.byType(LyricView));
      final document = view.controller.document!;
      final actualLines = document.lines
          .where((line) => line.text.isNotEmpty)
          .toList();
      expect(actualLines, hasLength(_lines.length));
      for (int index = 0; index < _lines.length; index++) {
        expect(
          actualLines[index].start,
          Duration(milliseconds: _lines[index].startMs),
        );
        expect(
          actualLines[index].end,
          Duration(milliseconds: _lines[index].endMs),
        );
        expect(actualLines[index].words, isNull);
        expect(actualLines[index].translation, isNull);
      }
      expect(document.lines.every((line) => line.words == null), isTrue);
      expect(document.lines, hasLength(_lines.length));
      expect(document.lines.every((line) => line.text.isNotEmpty), isTrue);
      expect(view.controller.timeOffset, const Duration(milliseconds: 175));
      expect(view.preset!.wordEffects.simulateTiming, isFalse);
      expect(view.preset!.highlight.enabled, isFalse);
      expect(find.byTooltip('隐藏译文'), findsNothing);
      expect(find.byTooltip('显示译文'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final selectedTrackId in <String?>[null, 'zh']) {
    testWidgets(
      'failed sheet selection retains ${selectedTrackId ?? 'Meting'} and shows error',
      (tester) async {
        final fixture = await _pumpPage(
          tester,
          selectedTrackId: selectedTrackId,
        );
        final document = tester
            .widget<LyricView>(find.byType(LyricView))
            .controller
            .document;
        fixture.repository.load = (_) async => throw StateError('unavailable');
        await _openSheet(tester);
        await tester.tap(find.text(_tracks.last.label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Meting歌词'), findsOneWidget);
        expect(find.text('字幕加载失败，请重试'), findsOneWidget);
        expect(fixture.value.selectedTrackId, selectedTrackId);
        expect(fixture.value.pendingTrackId, isNull);
        final selectedTitle = selectedTrackId == null
            ? 'Meting歌词'
            : _tracks.first.label;
        expect(_tile(tester, selectedTitle).selected, isTrue);
        expect(
          find.descendant(
            of: find.ancestor(
              of: find.text(selectedTitle),
              matching: find.byType(ListTile),
            ),
            matching: find.byIcon(Icons.check_rounded),
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        expect(
          find.byIcon(Icons.check_rounded, skipOffstage: false),
          findsOneWidget,
        );
        final retained = tester
            .widget<LyricView>(find.byType(LyricView))
            .controller
            .document!;
        expect(
          retained.lines.map(
            (line) => (line.text, line.start, line.end, line.translation),
          ),
          document!.lines.map(
            (line) => (line.text, line.start, line.end, line.translation),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('pending selection disables tracks but Meting can cancel it', (
    tester,
  ) async {
    final fixture = await _pumpPage(tester);
    final pending = Completer<List<BiliSubtitleLine>>();
    fixture.repository.load = (_) => pending.future;
    await _openSheet(tester);
    await tester.tap(find.text(_tracks.first.label));
    await tester.pump();
    expect(_tile(tester, _tracks.first.label).onTap, isNull);
    expect(_tile(tester, _tracks.last.label).onTap, isNull);
    expect(_tile(tester, 'Meting歌词').onTap, isNotNull);
    await tester.tap(find.text('Meting歌词'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    pending.complete(_lines);
    await tester.pump();
    expect(fixture.value.usesSubtitles, isFalse);
    expect(fixture.value.pendingTrackId, isNull);
    expect(find.text('Meting歌词'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'changing songs while sheet is open disables old tracks and Meting',
    (tester) async {
      final fixture = await _pumpPage(tester, selectedTrackId: 'zh');
      await _openSheet(tester);
      fixture.player.setItem(_item.copyWith(cid: 20));
      await tester.pump();
      expect(find.text('当前歌曲已变更，请重新打开字幕选择'), findsOneWidget);
      for (final title in [
        'Meting歌词',
        ..._tracks.map((track) => track.label),
      ]) {
        final tile = _tile(tester, title);
        expect(tile.onTap, isNull);
        expect(tile.selected, isFalse);
      }
      await tester.tap(find.text(_tracks.last.label));
      await tester.pump();
      expect(fixture.repository.loadedTracks, isEmpty);
      expect(fixture.value.selectedTrackId, 'zh');
      expect(find.text('Meting歌词'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

ListTile _tile(WidgetTester tester, String title) => tester.widget<ListTile>(
  find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
);

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byTooltip('AI字幕'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<_Fixture> _pumpPage(
  WidgetTester tester, {
  List<BiliSubtitleTrack> tracks = _tracks,
  String? selectedTrackId,
}) async {
  final fixture = _Fixture(tracks: tracks, selectedTrackId: selectedTrackId);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: fixture.container,
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              final player = ref.watch(playerControllerProvider);
              return PlayerLyricPage(
                state: player,
                item: player.currentItem,
                isActive: true,
                onSeek: (_) {},
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.container.dispose();
  });
  return fixture;
}

class _Fixture {
  _Fixture({
    required List<BiliSubtitleTrack> tracks,
    required String? selectedTrackId,
  }) : subtitles = _SubtitleController(
         PlayerSubtitleState(
           stableId: _item.stableId,
           tracks: tracks,
           selectedTrackId: selectedTrackId,
           lines: selectedTrackId == null ? const [] : _lines,
         ),
       ) {
    container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(() => player),
        metadataControllerProvider.overrideWith(_MetadataController.new),
        playerLyricSettingsLogicProvider.overrideWith(_LyricSettings.new),
        playerSubtitleControllerProvider.overrideWith(() => subtitles),
        biliSubtitleRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  final _PlayerController player = _PlayerController();
  final _SubtitleController subtitles;
  final _SubtitleRepository repository = _SubtitleRepository();
  late final ProviderContainer container;
  PlayerSubtitleState get value =>
      container.read(playerSubtitleControllerProvider);
}

class _SubtitleController extends PlayerSubtitleController {
  _SubtitleController(this.initial);
  final PlayerSubtitleState initial;
  @override
  PlayerSubtitleState build() => initial;
  void setValue(PlayerSubtitleState value) => state = value;
}

class _PlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    isReady: true,
    position: Duration(milliseconds: 1500),
    duration: Duration(seconds: 15),
  );
  void setItem(PlayableItem item) => state = state.copyWith(currentItem: item);
  void setPosition(Duration position) =>
      state = state.copyWith(position: position);
}

class _MetadataController extends MetadataController {
  @override
  MetadataState build() => MetadataState(
    stableId: _item.stableId,
    metadata: Metadata(
      stableId: _item.stableId,
      metaLyrics: const MetaLyrics(
        lyric: '[00:01.000]Meting第一行\n[00:04.000]Meting第二行',
        translatedLyric:
            '[00:01.000]Translation one\n[00:04.000]Translation two',
      ),
    ),
  );
}

class _LyricSettings extends PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() => const PlayerLyricSettings();
  @override
  Future<void> update(PlayerLyricSettings value) async => state = value;
}

class _SubtitleRepository implements BiliSubtitleRepository {
  final List<String> loadedTracks = [];
  Future<List<BiliSubtitleLine>> Function(BiliSubtitleTrack) load = (_) async =>
      _lines;

  @override
  Future<List<BiliSubtitleTrack>> fetchTracks(PlayableItem item) async =>
      _tracks;

  @override
  Future<List<BiliSubtitleLine>> fetchLines(BiliSubtitleTrack track) {
    loadedTracks.add(track.id);
    return load(track);
  }
}
