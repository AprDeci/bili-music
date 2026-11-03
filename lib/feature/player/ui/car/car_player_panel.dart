import 'package:bilimusic/common/components/queue_mode_icon.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarPlayerPanel extends ConsumerWidget {
  const CarPlayerPanel({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final display = ref.watch(playerDisplayProvider);
    final bool hasItem = ref.watch(
      playerControllerProvider.select((state) => state.hasItem),
    );

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
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
                borderRadius: BorderRadius.circular(20),
                child: PlayerArtworkFrame(
                  coverUrl: display.coverUrl ?? '',
                  borderRadius: 20,
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
          return Padding(
            padding: EdgeInsets.all(compact ? 8 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: compact
                      ? Row(
                          children: <Widget>[
                            SizedBox.square(dimension: 56, child: artwork),
                            const SizedBox(width: 12),
                            Expanded(child: title),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
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
                if (!compact && constraints.maxHeight < 560)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: '播放队列',
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),
                      onPressed: hasItem
                          ? () => showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              builder: (_) => const FractionallySizedBox(
                                heightFactor: 0.85,
                                child: SafeArea(child: _CarPlayerQueue()),
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.queue_music_rounded),
                    ),
                  ),
                const SizedBox(height: 8),
                CarPlayerControls(
                  compact: compact || constraints.maxHeight < 560,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CarPlayerControls extends ConsumerStatefulWidget {
  const CarPlayerControls({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<CarPlayerControls> createState() => _CarPlayerControlsState();
}

class _CarPlayerControlsState extends ConsumerState<CarPlayerControls> {
  double? _dragProgress;

  @override
  Widget build(BuildContext context) {
    final bool compact = widget.compact;
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
    final String? status = state.hasError
        ? state.errorMessage
        : switch (state.statusHint) {
            PlayerStatusHint.resolvingAudio => '正在解析音频',
            PlayerStatusHint.connectingStream => '正在连接音频',
            PlayerStatusHint.loadingCache => '正在加载缓存',
            PlayerStatusHint.buffering => '正在缓冲',
            PlayerStatusHint.error => '播放失败，请重试',
            null => state.isLoading ? '正在加载' : null,
          };

    Widget action({
      required String tooltip,
      required Widget icon,
      required VoidCallback? onPressed,
      bool primary = false,
    }) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: icon,
        iconSize: primary ? (compact ? 36 : 44) : (compact ? 28 : 36),
        style: IconButton.styleFrom(
          minimumSize: Size.square(primary && !compact ? 64 : 56),
          backgroundColor: primary ? theme.colorScheme.primaryContainer : null,
          foregroundColor: primary
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (status != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                status,
                maxLines: compact ? 1 : 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: state.hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        if (!compact)
          Tooltip(
            message: '播放进度',
            child: Semantics(
              label: '播放进度',
              child: SliderTheme(
                data: theme.sliderTheme.copyWith(
                  trackHeight: 5,
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 28,
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: Slider(
                    value: canSeek && _dragProgress != null
                        ? _dragProgress!
                        : milliseconds > 0
                        ? (progress.position.inMilliseconds / milliseconds)
                              .clamp(0.0, 1.0)
                        : 0,
                    label: formatPlayerDuration(progress.position),
                    semanticFormatterCallback: (double value) =>
                        formatPlayerDuration(
                          Duration(
                            milliseconds: (value * milliseconds).round(),
                          ),
                        ),
                    onChanged: canSeek
                        ? (double value) =>
                              setState(() => _dragProgress = value)
                        : null,
                    onChangeEnd: canSeek
                        ? (double value) {
                            setState(() => _dragProgress = null);
                            controller.seekFromProgressBar(
                              Duration(
                                milliseconds: (value * milliseconds).round(),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ),
          ),
        if (!compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                formatPlayerDuration(progress.position),
                style: theme.textTheme.labelLarge,
              ),
              Text(
                formatPlayerDuration(total),
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        if (!compact) const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 0,
          runSpacing: 8,
          children: <Widget>[
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
              primary: true,
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
            if (!compact)
              action(
                tooltip: '$modeLabel，切换播放模式',
                icon: queueModeIcon(state.queueMode),
                onPressed: state.hasQueue ? controller.toggleQueueMode : null,
              ),
            if (!compact)
              action(
                tooltip: '播放队列（${state.queue.length} 首）',
                icon: const Icon(Icons.queue_music_rounded),
                onPressed: state.hasQueue
                    ? () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (_) => const FractionallySizedBox(
                          heightFactor: 0.85,
                          child: SafeArea(child: _CarPlayerQueue()),
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _CarPlayerQueue extends ConsumerWidget {
  const _CarPlayerQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '播放队列 · ${state.queue.length} 首',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: '关闭播放队列',
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: !state.hasQueue
              ? const Center(child: Text('播放队列为空'))
              : ListView.builder(
                  itemCount: state.queue.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = state.queue[index];
                    final display = ref
                        .watch(playerQueueDisplayProvider(item))
                        .asData
                        ?.value;
                    return ListTile(
                      minTileHeight: 72,
                      selected: state.currentQueueIndex == index,
                      leading: Icon(
                        state.currentQueueIndex == index
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                      ),
                      title: Text(
                        display?.title ?? item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        display?.artist ?? item.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.skipToQueueIndex(index);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
