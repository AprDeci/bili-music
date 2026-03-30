import 'dart:math' as math;

import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicRankingSection extends ConsumerWidget {
  const MusicRankingSection({super.key});

  static const int _columnSize = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MusicRankingItem>> ranking = ref.watch(
      musicRankingProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '近期音乐热榜',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1329),
              fontSize: 18,
              letterSpacing: -1.3,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 340,
            child: ranking.when(
              data: (List<MusicRankingItem> items) {
                if (items.isEmpty) {
                  return const _MusicRankingEmpty();
                }
                return _MusicRankingPager(items: items);
              },
              loading: () => const _MusicRankingLoading(),
              error: (Object error, StackTrace stackTrace) {
                return _MusicRankingError(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(musicRankingProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicRankingPager extends StatelessWidget {
  const _MusicRankingPager({required this.items});

  final List<MusicRankingItem> items;

  @override
  Widget build(BuildContext context) {
    final List<List<MusicRankingItem>> columns = <List<MusicRankingItem>>[];
    for (
      int index = 0;
      index < items.length;
      index += MusicRankingSection._columnSize
    ) {
      final int end = math.min(
        index + MusicRankingSection._columnSize,
        items.length,
      );
      columns.add(items.sublist(index, end));
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double pageWidth = math.min(constraints.maxWidth * 0.9, 620);
        final double viewportFraction = constraints.maxWidth <= 0
            ? 1
            : pageWidth / constraints.maxWidth;

        return PageView.builder(
          controller: PageController(viewportFraction: viewportFraction),
          padEnds: false,
          itemCount: columns.length,
          itemBuilder: (BuildContext context, int index) {
            final bool isLastPage = index == columns.length - 1;

            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(right: isLastPage ? 0 : 20),
                child: SizedBox(
                  width: pageWidth,
                  child: _MusicRankingColumn(
                    items: columns[index],
                    startRank: index * MusicRankingSection._columnSize + 1,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MusicRankingLoading extends StatelessWidget {
  const _MusicRankingLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(3, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16),
          child: Row(
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 13,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MusicRankingError extends StatelessWidget {
  const _MusicRankingError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              size: 34,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 12),
            Text(
              '热榜加载失败',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicRankingEmpty extends StatelessWidget {
  const _MusicRankingEmpty();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Text(
        '暂无热榜内容',
        style: theme.textTheme.titleMedium?.copyWith(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MusicRankingColumn extends StatelessWidget {
  const _MusicRankingColumn({required this.items, required this.startRank});

  final List<MusicRankingItem> items;
  final int startRank;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 14),
          child: _MusicRankingTile(item: items[index], rank: startRank + index),
        );
      }),
    );
  }
}

class _MusicRankingTile extends StatelessWidget {
  const _MusicRankingTile({required this.item, required this.rank});

  final MusicRankingItem item;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: Row(
        children: <Widget>[
          _RankingCover(item: item, rank: rank),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    height: 1,
                    letterSpacing: -1.4,
                    color: const Color(0xFF0D1329),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    _TagBadge(label: item.tagText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF8A94A6),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const _PlayGlyph(),
        ],
      ),
    );
  }
}

class _RankingCover extends StatelessWidget {
  const _RankingCover({required this.item, required this.rank});

  final MusicRankingItem item;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: item.coverUrl.isEmpty
          ? Container(
              width: 44,
              height: 44,
              color: const Color(0xFFDDE6F2),
              child: const Icon(
                Icons.music_note_rounded,
                color: Color(0xFF64748B),
              ),
            )
          : Image.network(
              item.coverUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 88,
                  height: 88,
                  color: const Color(0xFFDDE6F2),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Color(0xFF64748B),
                  ),
                );
              },
            ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: primary.withValues(alpha: 0.35)),
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Color(0xFF53586C),
        size: 32,
      ),
    );
  }
}
