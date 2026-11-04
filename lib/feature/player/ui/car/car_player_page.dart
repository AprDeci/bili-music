import 'dart:async';

import 'package:bilimusic/common/components/car/car_cover_glow.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(56, 56),
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
