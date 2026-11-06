import 'package:bilimusic/common/components/queue_mode_icon.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_queue_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarPlayerPanel extends ConsumerWidget {
  const CarPlayerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final display = ref.watch(playerDisplayProvider);
    final bool hasItem = ref.watch(
      playerControllerProvider.select((state) => state.hasItem),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget artwork = Tooltip(
            message: '打开完整播放器',
            child: Semantics(
              button: true,
              label: '打开完整播放器',
              enabled: hasItem,
              child: InkWell(
                onTap: hasItem ? () => openPlayerPage(context) : null,
                borderRadius: BorderRadius.circular(8),
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
          final Widget title = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                display.title ?? '还没有播放内容',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                display.artist ?? '选一首音乐，开始旅程',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final double horizontalInset = ((constraints.maxWidth - 300) / 2)
              .clamp(17.0, double.infinity);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: artwork,
                              ),
                            ),
                          ),
                        ),
                        title,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Hero(
                  tag: 'car-player-controls',
                  createRectTween: (begin, end) =>
                      RectTween(begin: begin, end: end),
                  child: Material(
                    type: MaterialType.transparency,
                    child: CarPlayerControls(horizontalInset: horizontalInset),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CarPlayerControls extends ConsumerWidget {
  const CarPlayerControls({super.key, this.horizontalInset = 17});

  final double horizontalInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayerProgressSnapshot progress = resolvePlayerProgressSnapshot(
      ref.watch(playerProgressProvider),
      state,
    );
    final Duration total = progress.duration ?? Duration.zero;
    final double milliseconds = total.inMilliseconds.toDouble();
    final bool canSeek = progress.isReady && milliseconds > 0;
    final String modeLabel = switch (state.queueMode) {
      PlayerQueueMode.sequence => '顺序播放',
      PlayerQueueMode.singleRepeat => '单曲循环',
      PlayerQueueMode.shuffle => '随机播放',
    };


    const double edgeInset = (56 - 22) / 2;

    Widget action({
      required String tooltip,
      required Widget icon,
      required VoidCallback? onPressed,
      bool primary = false,
      double iconSize = 36,
      double edge = 0,
    }) {
      final double buttonSize = primary ? 64 : 56;
      return Transform.translate(
        offset: Offset(edge * ((buttonSize - iconSize) / 2 - edgeInset), 0),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: icon,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            fixedSize: Size.square(buttonSize),
            minimumSize: Size.square(buttonSize),
            visualDensity: VisualDensity.standard,
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            backgroundColor: primary
                ? theme.colorScheme.primaryContainer
                : null,
            foregroundColor: primary
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Tooltip(
          message: '播放进度',
          child: Semantics(
            label: '播放进度',
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalInset),
              child: PlayerProgressSection(
                position: progress.position,
                duration: progress.duration,
                isReady: canSeek,
                onChanged: (double value) => controller.seekFromProgressBar(
                  Duration(milliseconds: (value * milliseconds).round()),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalInset - edgeInset,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              action(
                tooltip: '$modeLabel，切换播放模式',
                icon: queueModeIcon(state.queueMode),
                iconSize: 22,
                edge: -1,
                onPressed: state.hasQueue ? controller.toggleQueueMode : null,
              ),
              action(
                tooltip: '上一首',
                icon: const Icon(Icons.skip_previous_rounded),
                onPressed: state.isReady && state.hasPrevious
                    ? controller.skipToPrevious
                    : null,
              ),
              action(
                tooltip: state.hasError
                    ? '重试播放'
                    : state.isPlaying
                    ? '暂停'
                    : '播放',
                primary: false,
                iconSize: 44,
                icon: state.isLoading || state.isBuffering
                    ? const SizedBox.square(
                        dimension: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Icon(
                        state.hasError
                            ? Icons.refresh_rounded
                            : state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                onPressed: state.hasQueue && !state.isLoading
                    ? () => state.hasError
                          ? controller.play()
                          : controller.togglePlayback()
                    : null,
              ),
              action(
                tooltip: '下一首',
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: state.isReady && state.hasNext
                    ? controller.skipToNext
                    : null,
              ),
              action(
                tooltip: '播放队列（${state.queue.length} 首）',
                icon: const Icon(Icons.queue_music_rounded),
                edge: 1,
                onPressed: state.hasQueue
                    ? () => showCarPlayerQueuePanel(context: context)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
