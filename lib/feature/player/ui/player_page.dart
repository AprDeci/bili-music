import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    ref.read(playerControllerProvider.notifier).loadFromItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(playerControllerProvider);
    final playerController = ref.read(playerControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final PlayableItem? item = state.currentItem ?? widget.initialItem;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF3F8FC), Color(0xFFE4EEF8), Color(0xFFD4E3F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          '正在播放',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF14324A),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: item == null
                            ? null
                            : () => playerController.loadFromItem(item),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _HeroArtwork(coverUrl: item?.coverUrl ?? ''),
                  const SizedBox(height: 28),
                  Text(
                    item?.title ?? '从搜索结果选择一条内容开始播放',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2742),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item == null
                        ? '全局播放器已就位，接下来只需要从搜索页点一个结果。'
                        : _buildSubtitle(item.author, state),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF52708A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _StatusCard(state: state),
                  const SizedBox(height: 24),
                  _ProgressCard(
                    state: state,
                    onChanged: (double value) {
                      final int totalMs =
                          (state.duration ?? Duration.zero).inMilliseconds;
                      final Duration position = Duration(
                        milliseconds: (totalMs * value).round(),
                      );
                      playerController.seek(position);
                    },
                  ),
                  const SizedBox(height: 18),
                  _ControlsCard(
                    state: state,
                    onBackward: () => playerController.seekBy(
                      const Duration(seconds: -10),
                    ),
                    onTogglePlayback: playerController.togglePlayback,
                    onForward: () => playerController.seekBy(
                      const Duration(seconds: 10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MetaPanel(state: state, item: item),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF0F2742), Color(0xFF3A6A8E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x330F2742),
              blurRadius: 40,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: coverUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.album_rounded,
                      size: 84,
                      color: Colors.white,
                    ),
                  )
                : Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.album_rounded,
                          size: 84,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String title = '准备播放';
    String message = '点击搜索结果后会自动解析视频音频流。';
    Color accent = const Color(0xFF2563EB);
    IconData icon = Icons.waves_rounded;

    if (state.isLoading) {
      title = '正在解析';
      message = '正在拉取视频详情与音频流信息，请稍候。';
      icon = Icons.radar_rounded;
      accent = const Color(0xFF1D4ED8);
    } else if (state.hasError) {
      title = '播放失败';
      message = state.errorMessage!;
      icon = Icons.error_outline_rounded;
      accent = const Color(0xFFDC2626);
    } else if (state.isPlaying) {
      title = '正在播放';
      message = '全局播放器已启动，离开当前页也可以继续保持状态。';
      icon = Icons.graphic_eq_rounded;
      accent = const Color(0xFF059669);
    } else if (state.isReady) {
      title = '已准备好';
      message = '音频流已就绪，可以开始或恢复播放。';
      icon = Icons.check_circle_outline_rounded;
      accent = const Color(0xFF0F766E);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E4EE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF526577),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state, required this.onChanged});

  final PlayerState state;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Duration total = state.duration ?? Duration.zero;
    final double progress = total.inMilliseconds <= 0
        ? 0
        : state.position.inMilliseconds / total.inMilliseconds;
    final double buffered = total.inMilliseconds <= 0
        ? 0
        : state.bufferedPosition.inMilliseconds / total.inMilliseconds;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E4EE)),
      ),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: buffered.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFFC2D7EA),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: state.isReady ? onChanged : null,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                _formatDuration(state.position),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF526577),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(total),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF526577),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.state,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final PlayerState state;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E4EE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton.filledTonal(
            onPressed: state.isReady ? onBackward : null,
            icon: const Icon(Icons.replay_10_rounded),
            iconSize: 28,
          ),
          FilledButton(
            onPressed: state.isReady ? onTogglePlayback : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(88, 88),
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF123857),
            ),
            child: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 42,
            ),
          ),
          IconButton.filledTonal(
            onPressed: state.isReady ? onForward : null,
            icon: const Icon(Icons.forward_10_rounded),
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}

class _MetaPanel extends StatelessWidget {
  const _MetaPanel({required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E4EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '播放信息',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF123857),
            ),
          ),
          const SizedBox(height: 14),
          _MetaRow(label: 'BV 号', value: item?.bvid ?? '--'),
          _MetaRow(
            label: 'AID',
            value: item == null ? '--' : item!.aid.toString(),
          ),
          _MetaRow(
            label: 'CID',
            value: state.audioStream == null
                ? '--'
                : state.audioStream!.cid.toString(),
          ),
          _MetaRow(
            label: '音质',
            value: state.audioStream?.qualityLabel ?? '--',
          ),
          _MetaRow(
            label: '时长',
            value: _formatDuration(state.duration ?? Duration.zero),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration value) {
  if (value <= Duration.zero) {
    return '00:00';
  }

  final int totalSeconds = value.inSeconds;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _buildSubtitle(String author, PlayerState state) {
  final String? pageTitle = state.audioStream?.pageTitle;
  if (pageTitle == null || pageTitle.isEmpty) {
    return author;
  }
  return '$author · $pageTitle';
}
