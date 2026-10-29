import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_online_audience_controller.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_cover_browser_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:bilimusic/feature/player/ui/desktop/desktop_player_bar.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Video title',
  author: 'Video UP',
  ownerMid: 123,
  coverUrl: '',
);

final Metadata _metadata = Metadata(
  stableId: _item.stableId,
  title: 'Song title',
  artist: 'Song artist',
);

void main() {
  testWidgets(
    'cover double tap switches page and mini information without artwork',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(tester, _metadata);

      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      expect(_metadata.albumArtUrl, isNull);
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isTrue,
      );
      expect(
        tester
            .widget<PlayerArtworkFrame>(find.byType(PlayerArtworkFrame))
            .coverUrl,
        isEmpty,
      );

      await _doubleTapCover(tester);

      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.bilibili,
      );
      _expectInformation(tester, _item.title, _item.author, opensUp: true);

      await _doubleTapCover(tester);

      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.metadata,
      );
      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late metadata updates both players and next item resets the switch',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(tester, null);
      final _FakeMetadataController metadataController =
          container.read(metadataControllerProvider.notifier)
              as _FakeMetadataController;
      final _FakePlayerController playerController =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final Completer<Metadata> result = Completer<Metadata>();
      final Future<void> pendingMetadata = metadataController.receive(
        result.future,
      );

      _expectInformation(tester, _item.title, _item.author, opensUp: true);
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      result.complete(_metadata);
      await pendingMetadata;
      await tester.pump();

      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      await _doubleTapCover(tester);
      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.bilibili,
      );
      _expectInformation(tester, _item.title, _item.author, opensUp: true);

      final PlayableItem nextItem = _item.copyWith(
        bvid: 'BV2xx411c7mD',
        title: 'Next video',
        author: 'Next UP',
        ownerMid: 456,
      );
      playerController.show(
        container
            .read(playerControllerProvider)
            .copyWith(currentItem: nextItem, queue: <PlayableItem>[nextItem]),
      );
      await tester.pump();

      expect(container.read(playerDisplaySourceLogicProvider), isNull);
      _expectInformation(
        tester,
        nextItem.title,
        nextItem.author,
        opensUp: true,
      );
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      metadataController.show(_metadata, stableId: nextItem.stableId);
      await tester.pump();

      _expectInformation(
        tester,
        nextItem.title,
        nextItem.author,
        opensUp: true,
      );
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      metadataController.show(
        Metadata(
          stableId: nextItem.stableId,
          title: 'Next song',
          artist: 'Next artist',
        ),
      );
      await tester.pump();

      _expectInformation(tester, 'Next song', 'Next artist', opensUp: false);
      playerController.show(
        container
            .read(playerControllerProvider)
            .copyWith(statusHint: PlayerStatusHint.buffering),
      );
      await tester.pump();

      final Finder miniPlayer = find.byType(MiniPlayerContent);
      expect(
        find.descendant(of: miniPlayer, matching: find.text('Next song')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: miniPlayer, matching: find.text('缓冲中...')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: miniPlayer, matching: find.text('Next artist')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop bar fits title artist and actions in its existing height',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        _metadata,
        size: const Size(1280, 900),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: DesktopPlayerBar(),
          ),
        ),
      );

      final Finder bar = find.byType(DesktopPlayerBar);
      expect(tester.getSize(bar).height, 76);
      expect(find.text('Song title'), findsOneWidget);
      expect(find.text('Song artist'), findsOneWidget);
      expect(
        tester.getRect(find.text('Song title')).bottom,
        lessThanOrEqualTo(tester.getRect(find.text('Song artist')).top),
      );
      expect(
        tester.getRect(find.text('Song artist')).bottom,
        lessThanOrEqualTo(tester.getRect(find.byTooltip('评论')).top),
      );
      expect(tester.takeException(), isNull);

      container.read(playerDisplaySourceLogicProvider.notifier).toggle();
      await tester.pump();

      expect(find.text(_item.title), findsOneWidget);
      expect(find.text(_item.author), findsOneWidget);
      expect(find.text('Song artist'), findsNothing);
      expect(tester.getSize(bar).height, 76);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'landscape places artwork beside active lyrics above shared controls',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        _metadata.copyWith(
          lyrics: '[00:00.000]First line\n[00:30.000]Next line',
        ),
        size: const Size(900, 420),
        home: const PlayerPage(initialItem: _item),
      );

      expect(find.byType(PlayerLandscapePage), findsOneWidget);
      expect(find.byType(PlayerArtworkFrame), findsOneWidget);
      expect(find.byType(PlayerLyricPage), findsOneWidget);
      expect(find.byType(PlayerProgressSection), findsOneWidget);
      expect(find.byType(PlayerLandscapeControls), findsOneWidget);
      expect(find.byType(PlayerTrackHeader), findsNothing);
      expect(find.byType(PlayerTopBar), findsNothing);
      expect(find.byType(PlayerDynamicBackdrop), findsOneWidget);
      expect(
        tester.getSize(find.byType(PlayerDynamicBackdrop)),
        const Size(900, 420),
      );
      final _FakeCoverColorController coverColor =
          container.read(playerCoverColorControllerProvider.notifier)
              as _FakeCoverColorController;
      for (final Color color in <Color>[Colors.blue, Colors.orange]) {
        coverColor.show(color);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<PlayerDynamicBackdrop>(find.byType(PlayerDynamicBackdrop))
              .baseColor,
          color,
        );
      }
      expect(find.byType(PageView), findsNothing);
      expect(find.text('Song title'), findsNothing);
      expect(find.text('Song artist'), findsNothing);
      final PlayerLyricPage lyrics = tester.widget<PlayerLyricPage>(
        find.byType(PlayerLyricPage),
      );
      expect(lyrics.isActive, isTrue);
      expect(lyrics.showToolbar, isFalse);
      for (final String tooltip in <String>[
        '手动匹配歌词',
        '歌词偏移',
        '歌词外观',
        '隐藏译文',
        '显示译文',
      ]) {
        expect(find.byTooltip(tooltip), findsNothing);
      }
      for (final String tooltip in <String>['上一首', '播放', '下一首', '播放队列']) {
        expect(find.byTooltip(tooltip), findsOneWidget);
      }
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Tooltip &&
              <String>['喜欢', '加入我喜欢'].contains(widget.message),
        ),
        findsOneWidget,
      );

      final Rect artwork = tester.getRect(find.byType(PlayerArtworkFrame));
      final Rect lyricPanel = tester.getRect(find.byType(PlayerLyricPage));
      final Rect progress = tester.getRect(find.byType(PlayerProgressSection));
      final Rect controls = tester.getRect(
        find.byType(PlayerLandscapeControls),
      );
      expect(artwork.right, lessThanOrEqualTo(lyricPanel.left));
      expect(artwork.width, closeTo(artwork.height, 0.01));
      expect(artwork.top, closeTo(lyricPanel.top, 0.01));
      expect(artwork.bottom + 8, closeTo(controls.bottom, 0.01));
      expect(
        tester
            .widget<ClipRRect>(
              find.descendant(
                of: find.byType(PlayerArtworkFrame),
                matching: find.byType(ClipRRect),
              ),
            )
            .borderRadius,
        BorderRadius.circular(8),
      );
      expect(artwork.width, lessThan(320));
      expect(artwork.top, greaterThan(32));
      expect(artwork.bottom, lessThan(388));
      final double centerY = tester
          .getRect(find.byType(PlayerLandscapePage))
          .center
          .dy;
      expect(artwork.center.dy, closeTo(centerY - 8, 0.01));
      expect(
        (lyricPanel.top + controls.bottom) / 2,
        closeTo(centerY - 4, 0.01),
      );
      expect(find.byTooltip('返回'), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      expect(lyricPanel.bottom, lessThanOrEqualTo(progress.top));
      expect(progress.bottom, lessThanOrEqualTo(controls.top));
      expect(find.byTooltip('播放模式'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(PlayerLandscapeControls),
          matching: find.byType(IconButton),
        ),
        findsNWidgets(5),
      );
      final double playX = tester.getCenter(find.byTooltip('播放')).dx;
      expect(playX, closeTo(controls.center.dx, 0.01));
      expect(
        playX - tester.getCenter(find.byTooltip('上一首')).dx,
        closeTo(tester.getCenter(find.byTooltip('下一首')).dx - playX, 0.01),
      );
      expect(
        playX - tester.getCenter(find.byTooltip('喜欢')).dx,
        closeTo(tester.getCenter(find.byTooltip('播放队列')).dx - playX, 0.01),
      );
      tester.view.physicalSize = const Size(420, 900);
      await tester.pumpAndSettle();
      expect(find.byType(PlayerMainPage), findsOneWidget);
      expect(
        tester
            .widget<ClipRRect>(
              find.descendant(
                of: find.byType(PlayerArtworkFrame),
                matching: find.byType(ClipRRect),
              ),
            )
            .borderRadius,
        BorderRadius.circular(8),
      );
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        1,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('landscape cover browses queue and only plays on confirmation', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPlayer(
      tester,
      _metadata,
      size: const Size(900, 420),
      home: const PlayerPage(initialItem: _item),
    );
    final _FakePlayerController player =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    final PlayableItem next = _item.copyWith(bvid: 'next', title: 'Next song');
    player.show(
      container
          .read(playerControllerProvider)
          .copyWith(queue: <PlayableItem>[_item, next]),
    );
    await tester.pump();
    final GestureDetector gesture = tester.widget<GestureDetector>(
      find
          .ancestor(
            of: find.byType(PlayerArtworkFrame),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(gesture.onDoubleTap, isNull);
    await tester.tap(find.byType(PlayerArtworkFrame));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerCoverBrowserPage), findsOneWidget);
    expect(find.text('Song title'), findsOneWidget);
    expect(container.read(playerDisplaySourceLogicProvider), isNull);
    final Finder carousel = find.byKey(
      const ValueKey<String>('player-cover-carousel'),
    );
    await tester.drag(carousel, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Next song'), findsOneWidget);
    expect(player.queueSelections, isEmpty);
    expect(container.read(playerControllerProvider).currentItem, _item);
    await tester.tap(
      find.byKey(ValueKey<String>('queue-cover-${next.contentId}')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PlayerCoverBrowserPage), findsNothing);
    expect(player.queueSelections, <int>[1]);
    expect(container.read(playerControllerProvider).currentItem, next);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cover browser starts at current track and back cancels preview',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        _metadata,
        size: const Size(640, 320),
        textScaler: TextScaler.linear(2),
        padding: const EdgeInsets.fromLTRB(44, 8, 20, 16),
        home: const PlayerPage(initialItem: _item),
      );
      final _FakePlayerController player =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final PlayableItem previous = _item.copyWith(bvid: 'previous');
      player.show(
        container
            .read(playerControllerProvider)
            .copyWith(
              queue: <PlayableItem>[previous, _item],
              currentQueueIndex: 1,
            ),
      );
      await tester.pump();
      await tester.tap(find.byType(PlayerArtworkFrame));
      await tester.pumpAndSettle();
      final PageView carousel = tester.widget<PageView>(
        find.byKey(const ValueKey<String>('player-cover-carousel')),
      );
      expect(carousel.controller!.page, 1);
      expect(find.text('Song title'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(PageView).last, const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('返回播放器'));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerCoverBrowserPage), findsNothing);
      expect(player.queueSelections, isEmpty);
      expect(container.read(playerControllerProvider).currentItem, _item);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('confirming the current cover preserves playback position', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPlayer(
      tester,
      _metadata,
      size: const Size(900, 420),
      home: const PlayerPage(initialItem: _item),
    );
    final _FakePlayerController player =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    player.show(
      container
          .read(playerControllerProvider)
          .copyWith(position: const Duration(seconds: 42)),
    );
    await tester.pump();
    await tester.tap(find.byType(PlayerArtworkFrame));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('queue-cover-${_item.contentId}')),
    );
    await tester.pumpAndSettle();
    expect(player.queueSelections, isEmpty);
    expect(
      container.read(playerControllerProvider).position,
      const Duration(seconds: 42),
    );
    expect(find.byType(PlayerCoverBrowserPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cover confirmation resolves the live queue after reordering', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPlayer(
      tester,
      _metadata,
      size: const Size(900, 420),
      home: const PlayerPage(initialItem: _item),
    );
    final _FakePlayerController player =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    final PlayableItem next = _item.copyWith(bvid: 'next', title: 'Next song');
    player.show(
      container
          .read(playerControllerProvider)
          .copyWith(queue: <PlayableItem>[_item, next]),
    );
    await tester.pump();
    await tester.tap(find.byType(PlayerArtworkFrame));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    player.show(
      container
          .read(playerControllerProvider)
          .copyWith(queue: <PlayableItem>[next, _item], currentQueueIndex: 1),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(ValueKey<String>('queue-cover-${next.contentId}')),
    );
    await tester.pumpAndSettle();
    expect(player.queueSelections, <int>[0]);
    expect(container.read(playerControllerProvider).currentItem, next);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape aligns lyrics progress labels and control edges', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPlayer(
      tester,
      _metadata.copyWith(lyrics: '[00:00.000]First line\n[00:30.000]Next line'),
      size: const Size(900, 420),
      home: const PlayerPage(initialItem: _item),
    );
    final _FakeLyricSettingsLogic settings =
        container.read(playerLyricSettingsLogicProvider.notifier)
            as _FakeLyricSettingsLogic;
    for (final double padding in <double>[0, 24, 36]) {
      settings.show(PlayerLyricSettings(horizontalPadding: padding));
      await tester.pump();
      final Finder lyrics = find.byType(LyricView);
      final Rect content = tester
          .widget<LyricView>(lyrics)
          .preset!
          .padding
          .resolve(TextDirection.ltr)
          .deflateRect(tester.getRect(lyrics));
      for (final Type type in <Type>[
        PlayerProgressSection,
        Slider,
        PlayerLandscapeControls,
      ]) {
        final Rect rect = tester.getRect(find.byType(type));
        expect(rect.left, closeTo(content.left, 0.01));
        expect(rect.right, closeTo(content.right, 0.01));
      }
      final Finder labels = find.descendant(
        of: find.byType(PlayerProgressSection),
        matching: find.byType(Text),
      );
      expect(tester.getRect(labels.first).left, closeTo(content.left, 0.01));
      expect(tester.getRect(labels.last).right, closeTo(content.right, 0.01));
      expect(
        tester.widget<Slider>(find.byType(Slider)).padding,
        EdgeInsets.zero,
      );
      expect(
        tester.getSize(find.byType(Slider)).height,
        greaterThanOrEqualTo(48),
      );
      final Finder buttons = find.descendant(
        of: find.byType(PlayerLandscapeControls),
        matching: find.byType(IconButton),
      );
      final Widget firstIcon = tester.widget<IconButton>(buttons.first).icon;
      final Widget lastIcon = tester.widget<IconButton>(buttons.last).icon;
      expect(
        tester.getRect(find.byWidget(firstIcon)).left,
        closeTo(content.left, 0.01),
      );
      expect(
        tester.getRect(find.byWidget(lastIcon)).right,
        closeTo(content.right, 0.01),
      );
      for (final Element button in buttons.evaluate()) {
        final Size size = tester.getSize(find.byWidget(button.widget));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      expect(tester.takeException(), isNull);
    }
    tester.view.physicalSize = const Size(420, 900);
    await tester.pumpAndSettle();
    final Rect slider = tester.getRect(find.byType(Slider));
    final Finder labels = find.descendant(
      of: find.byType(PlayerProgressSection),
      matching: find.byType(Text),
    );
    expect(tester.getRect(labels.first).left, closeTo(slider.left, 0.01));
    expect(tester.getRect(labels.last).right, closeTo(slider.right, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape controls use the existing playback callbacks', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPlayer(
      tester,
      _metadata,
      size: const Size(900, 420),
      home: const PlayerPage(initialItem: _item),
    );
    final _FakePlayerController player =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    player.show(
      container
          .read(playerControllerProvider)
          .copyWith(
            queue: <PlayableItem>[
              _item,
              _item.copyWith(bvid: 'BV2xx411c7mD'),
            ],
          ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('播放'));
    await tester.pump();
    expect(player.togglePlaybackCalls, 1);
    expect(find.byTooltip('暂停'), findsOneWidget);
    await tester.tap(find.byTooltip('暂停'));
    await tester.pump();
    expect(player.togglePlaybackCalls, 2);
    expect(container.read(playerControllerProvider).isPlaying, isFalse);

    await tester.tap(find.byTooltip('上一首'));
    await tester.tap(find.byTooltip('下一首'));
    expect(player.previousCalls, 1);
    expect(player.nextCalls, 1);

    expect(find.byTooltip('播放模式'), findsNothing);
    expect(
      container.read(playerControllerProvider).queueMode,
      PlayerQueueMode.sequence,
    );

    final Rect track = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(track.left + track.width / 4, track.center.dy));
    await tester.pump();
    expect(player.progressSeeks, hasLength(1));
    expect(player.progressSeeks.single.inSeconds, closeTo(45, 1));
    expect(container.read(playerControllerProvider).isPlaying, isTrue);
    tester
        .widget<PlayerLyricPage>(find.byType(PlayerLyricPage))
        .onSeek(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 300));
    expect(player.lyricSeeks, <Duration>[const Duration(seconds: 12)]);
    expect(player.progressSeeks, hasLength(1));
    expect(
      tester.widget<Slider>(find.byType(Slider)).value,
      closeTo(12 / 180, 0.001),
    );

    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pump();
    tester
        .widget<PlayerLyricPage>(find.byType(PlayerLyricPage))
        .onSeek(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester.widget<Slider>(find.byType(Slider)).value,
      closeTo(12 / 180, 0.001),
    );

    await tester.tap(find.byTooltip('播放队列'));
    await tester.pumpAndSettle();
    expect(find.text('播放队列'), findsOneWidget);
    expect(find.text('2 项 · 列表循环'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rotation preserves playback and the selected portrait lyric tab',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        _metadata,
        home: const PlayerPage(initialItem: _item),
      );
      final _FakePlayerController player =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final PlayerState playing = container
          .read(playerControllerProvider)
          .copyWith(
            queue: <PlayableItem>[
              _item,
              _item.copyWith(bvid: 'BV2xx411c7mD'),
            ],
            queueMode: PlayerQueueMode.shuffle,
            queueSourceLabel: 'Saved queue',
            position: const Duration(seconds: 42),
            isPlaying: true,
          );
      player.show(playing);
      await tester.pump();
      expect(find.byType(PlayerMainPage), findsOneWidget);
      expect(find.byType(PlayerTrackHeader), findsOneWidget);
      expect(find.byType(PlayerTopBar), findsOneWidget);
      expect(find.byType(PlayerDynamicBackdrop), findsOneWidget);
      expect(
        tester.widget<PageView>(find.byType(PageView)).key,
        const PageStorageKey<String>('playerPages'),
      );

      await tester.drag(find.byType(PageView), const Offset(-380, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        2,
      );
      expect(find.byTooltip('手动匹配歌词'), findsOneWidget);
      final State portraitPage = tester.state(find.byType(PlayerPage));

      tester.view.physicalSize = const Size(900, 420);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(PlayerPage)), same(portraitPage));
      expect(find.byType(PlayerLandscapePage), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      expect(find.byTooltip('手动匹配歌词'), findsNothing);
      expect(container.read(playerControllerProvider), playing);
      expect(
        tester
            .widget<PlayerProgressSection>(find.byType(PlayerProgressSection))
            .position,
        playing.position,
      );

      tester.view.physicalSize = const Size(420, 900);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(PlayerPage)), same(portraitPage));
      expect(find.byType(PlayerLandscapePage), findsNothing);
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        2,
      );
      expect(
        tester.widget<PlayerTopBar>(find.byType(PlayerTopBar)).currentPage,
        2,
      );
      final PlayerLyricPage lyrics = tester.widget<PlayerLyricPage>(
        find.byType(PlayerLyricPage),
      );
      expect(lyrics.isActive, isTrue);
      expect(lyrics.showToolbar, isTrue);
      expect(find.byTooltip('手动匹配歌词'), findsOneWidget);
      expect(container.read(playerControllerProvider), playing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('compact dark landscape respects safe insets and large text', (
    WidgetTester tester,
  ) async {
    const Size size = Size(640, 320);
    const EdgeInsets padding = EdgeInsets.fromLTRB(44, 8, 20, 16);
    await _pumpPlayer(
      tester,
      _metadata.copyWith(lyrics: '[00:00.000]First line\n[00:30.000]Next line'),
      size: size,
      padding: padding,
      textScaler: TextScaler.linear(2),
      theme: ThemeData.dark(),
      home: const PlayerPage(initialItem: _item),
    );

    expect(find.byType(PlayerLandscapePage), findsOneWidget);
    final BuildContext context = tester.element(
      find.byType(PlayerLandscapePage),
    );
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(MediaQuery.textScalerOf(context).scale(10), 20);
    final Rect artwork = tester.getRect(find.byType(PlayerArtworkFrame));
    expect(
      artwork.top,
      closeTo(tester.getRect(find.byType(PlayerLyricPage)).top, 0.01),
    );
    expect(
      tester.getRect(find.byType(PlayerLandscapeControls)).bottom,
      closeTo(artwork.bottom + 8, 0.01),
    );
    final Rect safeRect = Rect.fromLTRB(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
    );
    for (final Type type in <Type>[
      PlayerArtworkFrame,
      PlayerLyricPage,
      PlayerProgressSection,
      PlayerLandscapeControls,
    ]) {
      final Rect rect = tester.getRect(find.byType(type));
      expect(rect.width, greaterThan(0));
      expect(rect.height, greaterThan(0));
      expect(rect.left, greaterThanOrEqualTo(safeRect.left));
      expect(rect.top, greaterThanOrEqualTo(safeRect.top));
      expect(rect.right, lessThanOrEqualTo(safeRect.right));
      expect(rect.bottom, lessThanOrEqualTo(safeRect.bottom));
    }
    expect(tester.takeException(), isNull);
  });

  for (final String status in <String>[
    'loading',
    'missing',
    'error',
    'empty',
  ]) {
    testWidgets('compact landscape fits $status lyrics with large text', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        status == 'loading' ? null : _metadata,
        size: const Size(640, 320),
        padding: const EdgeInsets.fromLTRB(44, 8, 20, 16),
        textScaler: TextScaler.linear(2),
        home: const PlayerPage(),
      );
      if (status == 'error') {
        (container.read(metadataControllerProvider.notifier)
                as _FakeMetadataController)
            .fail('歌词查询失败，请重试');
      } else if (status == 'empty') {
        (container.read(playerControllerProvider.notifier)
                as _FakePlayerController)
            .show(const PlayerState());
      }
      await tester.pump();
      expect(find.byType(PlayerLandscapePage), findsOneWidget);
      expect(find.byType(PlayerLandscapeControls), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<ProviderContainer> _pumpPlayer(
  WidgetTester tester,
  Metadata? metadata, {
  Size size = const Size(420, 900),
  Widget? home,
  EdgeInsets padding = EdgeInsets.zero,
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(_FakeFavoritesController.new),
        playerControllerProvider.overrideWith(_FakePlayerController.new),
        metadataControllerProvider.overrideWith(
          () => _FakeMetadataController(metadata),
        ),
        playerCoverColorControllerProvider.overrideWith(
          _FakeCoverColorController.new,
        ),
        playerLyricSettingsLogicProvider.overrideWith(
          _FakeLyricSettingsLogic.new,
        ),
        playerOnlineAudienceControllerProvider.overrideWith(
          _FakeOnlineAudienceController.new,
        ),
        playerDisplaySettingsLogicProvider.overrideWithValue(true),
        desktopLyricsControllerProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        theme: theme,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: padding,
            viewPadding: padding,
            textScaler: textScaler,
          ),
          child: child!,
        ),
        home:
            home ??
            Scaffold(
              body: Column(
                children: <Widget>[
                  const Expanded(child: PlayerPage(initialItem: _item)),
                  HeroMode(
                    enabled: false,
                    child: Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                            return MiniPlayerContent(
                              state: ref.watch(playerControllerProvider),
                              onTogglePlayback: () {},
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
    listen: false,
  );
}

Future<void> _doubleTapCover(WidgetTester tester) async {
  final Finder cover = find.byType(PlayerArtworkFrame);
  await tester.tap(cover);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(cover);
  await tester.pump(const Duration(milliseconds: 300));
}

void _expectInformation(
  WidgetTester tester,
  String title,
  String artist, {
  required bool opensUp,
}) {
  final PlayerTrackHeader header = tester.widget<PlayerTrackHeader>(
    find.byType(PlayerTrackHeader),
  );
  expect(header.title, title);
  expect(header.subtitle, artist);
  expect(header.onSubtitleTap, opensUp ? isNotNull : isNull);
  final Finder headerWidget = find.byType(PlayerTrackHeader);
  expect(
    find.descendant(of: headerWidget, matching: find.text(title)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: headerWidget, matching: find.text(artist)),
    findsOneWidget,
  );
  final Finder miniPlayer = find.byType(MiniPlayerContent);
  expect(
    find.descendant(of: miniPlayer, matching: find.text(title)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: miniPlayer, matching: find.text(artist)),
    findsOneWidget,
  );
}

class _FakeFavoritesController extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();
}

class _FakePlayerController extends PlayerController {
  int togglePlaybackCalls = 0;
  int previousCalls = 0;
  int nextCalls = 0;
  final List<int> queueSelections = <int>[];
  final List<Duration> progressSeeks = <Duration>[];
  final List<Duration> lyricSeeks = <Duration>[];

  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    queue: <PlayableItem>[_item],
    currentQueueIndex: 0,
    isReady: true,
    duration: Duration(minutes: 3),
  );

  void show(PlayerState value) => state = value;

  @override
  Future<void> togglePlayback() async {
    togglePlaybackCalls++;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {
    queueSelections.add(index);
    state = state.copyWith(
      currentItem: state.queue[index],
      currentQueueIndex: index,
      position: Duration.zero,
      isPlaying: autoplay,
    );
  }

  @override
  Future<void> skipToPrevious() async => previousCalls++;

  @override
  Future<void> skipToNext() async => nextCalls++;

  @override
  void toggleQueueMode() {
    state = state.copyWith(
      queueMode: PlayerQueueMode
          .values[(state.queueMode.index + 1) % PlayerQueueMode.values.length],
    );
  }

  @override
  Future<void> seek(Duration position) async {
    lyricSeeks.add(position);
    state = state.copyWith(position: position);
  }

  @override
  Future<void> seekFromProgressBar(Duration position) async {
    progressSeeks.add(position);
    state = state.copyWith(position: position, isPlaying: true);
  }
}

class _FakeMetadataController extends MetadataController {
  _FakeMetadataController(this.metadata);

  final Metadata? metadata;

  @override
  MetadataState build() => MetadataState(
    stableId: _item.stableId,
    metadata: metadata,
    isLoading: metadata == null,
    hasSearched: metadata != null,
  );

  Future<void> receive(Future<Metadata> result) async => show(await result);

  void fail(String message) {
    state = MetadataState(stableId: _item.stableId, errorMessage: message);
  }

  void show(Metadata value, {String? stableId}) {
    state = MetadataState(
      stableId: stableId ?? value.stableId,
      metadata: value,
      hasSearched: true,
    );
  }
}

class _FakeCoverColorController extends PlayerCoverColorController {
  @override
  Color? build() => null;

  void show(Color color) => state = color;
}

class _FakeLyricSettingsLogic extends PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() => const PlayerLyricSettings();

  void show(PlayerLyricSettings value) => state = value;
}

class _FakeOnlineAudienceController extends PlayerOnlineAudienceController {
  @override
  PlayerOnlineAudience? build() => null;
}
