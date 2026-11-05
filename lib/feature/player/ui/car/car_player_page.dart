import 'dart:async';

import 'package:bilimusic/common/components/car/car_cover_glow.dart';
import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_settings_sheet.dart';
import 'package:bilimusic/feature/player/domain/player_playback_speed.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

enum _CarPlayerMenuAction {
  sleep,
  speed,
  lyrics,
  quality,
  collection,
  comments,
}

class CarPlayerPage extends ConsumerStatefulWidget {
  const CarPlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<CarPlayerPage> createState() => _CarPlayerPageState();
}

class _CarPlayerPageState extends ConsumerState<CarPlayerPage> {
  String? _initialError;

  @override
  void initState() {
    super.initState();
    _scheduleInitialItem();
  }

  @override
  void didUpdateWidget(covariant CarPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      _scheduleInitialItem();
    }
  }

  void _scheduleInitialItem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadInitialItem());
      }
    });
  }

  Future<void> _loadInitialItem() async {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    if (_initialError != null) {
      setState(() => _initialError = null);
    }
    final PlayerState state = ref.read(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    try {
      if (state.currentItem?.stableId == item.stableId) {
        if (!state.isReady && !state.isLoading) {
          await controller.play();
        }
        return;
      }
      if (!state.queue.any((queued) => queued.stableId == item.stableId)) {
        await controller.enqueue(<PlayableItem>[item]);
      }
      if (!mounted || widget.initialItem != item) {
        return;
      }
      final PlayerState current = ref.read(playerControllerProvider);
      final int index = current.queue.indexWhere(
        (queued) => queued.stableId == item.stableId,
      );
      if (index < 0) {
        return;
      }
      if (current.currentItem?.stableId == item.stableId) {
        await controller.play();
      } else {
        await controller.skipToQueueIndex(index);
      }
    } on Object {
      if (mounted && widget.initialItem == item) {
        setState(() => _initialError = '无法载入播放内容，请重试');
      }
    }
  }

  Future<void> _showMenu() async {
    final PlayerState state = ref.read(playerControllerProvider);
    final PlayableItem? item = state.currentItem;
    final List<AudioQualityOption> qualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];
    final _CarPlayerMenuAction?
    action = await showCarSidePanel<_CarPlayerMenuAction>(
      context: context,
      width: 360,
      height: 392,
      alignment: Alignment.topRight,
      slideFrom: const Offset(0, 1),
      builder: (context) => GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 112 * MediaQuery.textScalerOf(context).scale(16) / 16,
        ),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final (action, icon, label, enabled) in [
            (_CarPlayerMenuAction.sleep, Icons.timer_outlined, '定时关闭', true),
            (_CarPlayerMenuAction.speed, Icons.speed_rounded, '倍速播放', true),
            (_CarPlayerMenuAction.lyrics, Icons.lyrics_outlined, '歌词设置', true),
            (
              _CarPlayerMenuAction.quality,
              Icons.high_quality_outlined,
              '音质设置',
              item != null && qualities.isNotEmpty,
            ),
            (
              _CarPlayerMenuAction.collection,
              Icons.playlist_add_rounded,
              '添加到歌单',
              item != null,
            ),
            (
              _CarPlayerMenuAction.comments,
              Icons.comment_outlined,
              '查看评论',
              item != null && item.aid > 0,
            ),
          ])
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: enabled
                  ? () => Navigator.of(context).pop(action)
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon),
                  const SizedBox(height: 8),
                  Text(label, textAlign: TextAlign.center),
                  if (action == _CarPlayerMenuAction.speed)
                    Text(formatPlaybackSpeed(state.speed)),
                ],
              ),
            ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _CarPlayerMenuAction.sleep:
        await showCarSidePanel<void>(
          context: context,
          width: 480,
          alignment: Alignment.centerRight,
          slideFrom: const Offset(1, 0),
          builder: (_) => const SleepTimerPage(),
        );
      case _CarPlayerMenuAction.speed:
        final double? speed = await showCarSidePanel<double>(
          context: context,
          width: 360,
          height: 432,
          alignment: Alignment.topRight,
          slideFrom: const Offset(1, 0),
          builder: (context) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: <Widget>[
              for (final speed in kPlayerPlaybackSpeeds)
                ListTile(
                  minTileHeight: 80,
                  title: Text(formatPlaybackSpeed(speed)),
                  selected: speed == state.speed,
                  trailing: speed == state.speed
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(speed),
                ),
            ],
          ),
        );
        if (!mounted || speed == null) return;
        try {
          await ref.read(playerControllerProvider.notifier).setSpeed(speed);
        } on Object {
          if (mounted) ToastUtil.show('倍速设置失败，请重试');
        }
      case _CarPlayerMenuAction.lyrics:
        await showPlayerLyricSettings(
          context,
          activeColor: ref.read(playerCoverColorControllerProvider),
        );
      case _CarPlayerMenuAction.quality:
        final AudioQualityOption? quality =
            await showCarSidePanel<AudioQualityOption>(
              context: context,
              width: 360,
              height: 352,
              alignment: Alignment.topRight,
              slideFrom: const Offset(1, 0),
              builder: (context) => ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: <Widget>[
                  for (final option in qualities)
                    ListTile(
                      minTileHeight: 80,
                      title: Text(option.label),
                      selected: option.isSelected,
                      trailing: option.isSelected
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                ],
              ),
            );
        if (!mounted || quality == null) return;
        try {
          await ref
              .read(playerControllerProvider.notifier)
              .switchCurrentAudioQuality(quality.qualityId);
        } on Object {
          if (mounted) ToastUtil.show('音质切换失败，请重试');
        }
      case _CarPlayerMenuAction.collection:
        if (item == null) return;
        await showPlayerCollectionItemsSheet(
          context: context,
          items: <PlayableItem>[item],
          carStyle: true,
        );
      case _CarPlayerMenuAction.comments:
        if (item == null || item.aid <= 0) return;
        await showCarSidePanel<void>(
          context: context,
          alignment: Alignment.centerRight,
          slideFrom: const Offset(1, 0),
          builder: (_) => CommentPage(
            target: CommentTarget.video(
              aid: item.aid,
              bvid: item.bvid,
              title: item.title,
              coverUrl: item.coverUrl,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PlayerState state = ref.watch(playerControllerProvider);
    final display = ref.watch(playerDisplayProvider);
    final bool showTranslation = ref.watch(
      playerLyricSettingsLogicProvider.select(
        (settings) => settings.showTranslation,
      ),
    );
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 64,
        leading: IconButton(
          tooltip: '返回',
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '播放器菜单',
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: _showMenu,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMenuSquare,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(child: CarCoverGlow(bottom: true)),
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double textScale =
                    MediaQuery.textScalerOf(context).scale(16) / 16;
                final double minimumHeight = 480 * textScale.clamp(1.0, 2.0);
                final double height = constraints.maxHeight.clamp(
                  minimumHeight,
                  double.infinity,
                );
                final double horizontalInset = (constraints.maxWidth * 0.055)
                    .clamp(16.0, 72.0);
                final double bottomInset = (height * 0.12).clamp(24.0, 80.0);
                final Widget artwork = Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Semantics(
                      image: true,
                      label: '${display.title ?? '暂无播放内容'}封面',
                      child: Hero(
                        tag: 'car-player-artwork',
                        child: PlayerArtworkFrame(
                          coverUrl: display.coverUrl ?? '',
                          fallback: ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 84,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                final Widget lyricsAndControls = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      display.title ?? '还没有播放内容',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      display.artist ?? '选择一首音乐，开始旅程',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_initialError != null)
                      Semantics(
                        liveRegion: true,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(56, 56),
                            foregroundColor: theme.colorScheme.error,
                          ),
                          onPressed: _loadInitialItem,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(_initialError!),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Theme(
                        data: theme.copyWith(
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(56, 56),
                            ),
                          ),
                          filledButtonTheme: FilledButtonThemeData(
                            style: theme.filledButtonTheme.style?.copyWith(
                              minimumSize: const WidgetStatePropertyAll(
                                Size(56, 56),
                              ),
                            ),
                          ),
                        ),
                        child: PlayerLyricPanel(
                          state: state,
                          item: state.currentItem,
                          isActive: true,
                          onSeek: state.isReady
                              ? controller.seekFromProgressBar
                              : (_) {},
                          activeColor: coverColor,
                          variant: PlayerLyricPanelVariant.desktop,
                          showTranslation: showTranslation,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.currentItem != null)
                      PlayerLyricToolbar(
                        item: state.currentItem!,
                        activeColor: coverColor,
                        carMode: true,
                      ),
                    Hero(
                      tag: 'car-player-controls',
                      createRectTween: (begin, end) =>
                          RectTween(begin: begin, end: end),
                      child: const Material(
                        type: MaterialType.transparency,
                        child: CarPlayerControls(),
                      ),
                    ),
                  ],
                );

                return SingleChildScrollView(
                  child: SizedBox(
                    height: height,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalInset,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 24,
                              ),
                              child: lyricsAndControls,
                            ),
                          ),
                          SizedBox(width: horizontalInset),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 24,
                                bottom: bottomInset,
                              ),
                              child: artwork,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
