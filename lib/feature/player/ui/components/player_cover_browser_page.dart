import 'dart:math' as math;

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerCoverBrowserPage extends ConsumerStatefulWidget {
  const PlayerCoverBrowserPage({
    super.key,
    required this.queue,
    required this.initialIndex,
    this.activeColor,
  }) : assert(queue.length > 0),
       assert(initialIndex >= 0 && initialIndex < queue.length);

  final List<PlayableItem> queue;
  final int initialIndex;
  final Color? activeColor;

  @override
  ConsumerState<PlayerCoverBrowserPage> createState() =>
      _PlayerCoverBrowserPageState();
}

class _PlayerCoverBrowserPageState
    extends ConsumerState<PlayerCoverBrowserPage> {
  late int _previewIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final PlayableItem item = widget.queue[_previewIndex];
    final PlayerDisplayInfo display =
        ref.watch(playerQueueDisplayProvider(item)).asData?.value ??
        resolvePlayerDisplayInfo(
          item: item,
          metadata: null,
          source: PlayerDisplaySource.bilibili,
        );
    final Color? color =
        ref
            .watch(playerArtworkColorProvider(display.coverUrl ?? ''))
            .asData
            ?.value ??
        widget.activeColor;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: PlayerDynamicBackdrop(baseColor: color)),
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double extent = math.min(
                            constraints.maxHeight,
                            constraints.maxWidth * 0.72,
                          );
                          return _CoverCarousel(
                            key: ValueKey<Size>(constraints.biggest),
                            queue: widget.queue,
                            initialIndex: _previewIndex,
                            viewportFraction: extent / constraints.maxWidth,
                            onPageChanged: (int index) {
                              setState(() => _previewIndex = index);
                            },
                            onConfirm: (PlayableItem selected) {
                              Navigator.of(context).pop(selected);
                            },
                          );
                        },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        display.title ?? item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        display.artist ?? item.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            child: SafeArea(
              child: IconButton(
                tooltip: '返回播放器',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverCarousel extends ConsumerStatefulWidget {
  const _CoverCarousel({
    super.key,
    required this.queue,
    required this.initialIndex,
    required this.viewportFraction,
    required this.onPageChanged,
    required this.onConfirm,
  });

  final List<PlayableItem> queue;
  final int initialIndex;
  final double viewportFraction;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<PlayableItem> onConfirm;

  @override
  ConsumerState<_CoverCarousel> createState() => _CoverCarouselState();
}

class _CoverCarouselState extends ConsumerState<_CoverCarousel> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
    viewportFraction: widget.viewportFraction,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const ValueKey<String>('player-cover-carousel'),
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.queue.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayableItem item = widget.queue[index];
        final PlayerDisplayInfo? display = ref
            .watch(playerQueueDisplayProvider(item))
            .asData
            ?.value;
        return AnimatedBuilder(
          animation: _controller,
          child: Semantics(
            button: true,
            label: '播放 ${display?.title ?? item.title}',
            child: GestureDetector(
              key: ValueKey<String>('queue-cover-${item.contentId}'),
              onTap: () {
                final double page =
                    _controller.page ?? widget.initialIndex.toDouble();
                if ((page - index).abs() > 0.01) {
                  _controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                  return;
                }
                widget.onConfirm(item);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: PlayerArtworkFrame(
                  coverUrl: display?.coverUrl ?? item.coverUrl,
                ),
              ),
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            final double page =
                _controller.hasClients &&
                    _controller.position.hasContentDimensions
                ? _controller.page ?? widget.initialIndex.toDouble()
                : widget.initialIndex.toDouble();
            final double distance = (index - page).clamp(-1.0, 1.0);
            return FractionalTranslation(
              translation: Offset(-(index - page) * 0.18, 0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(-distance * 0.65),
                child: Transform.scale(
                  scale: 1 - distance.abs() * 0.2,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
