import 'dart:math' as math;

import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicRankingSection extends ConsumerWidget {
  const MusicRankingSection({super.key});

  static const int _columnSize = 3;
  static const int _sectionCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MusicRankingItem>> ranking = ref.watch(
      musicRankingControllerProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '近期音乐区热榜',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1329),
              fontSize: 18,
              letterSpacing: -1.3,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          ranking.when(
            data: (List<MusicRankingItem> items) {
              if (items.isEmpty) {
                return const _MusicRankingEmpty();
              }

              return _MusicRankingSplitView(
                items: items,
                onItemTap: (int index) {
                  _handleItemTap(context, ref, items, index);
                },
              );
            },
            loading: () => const _MusicRankingLoading(),
            error: (Object error, StackTrace stackTrace) {
              return _MusicRankingError(message: error.toString());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleItemTap(
    BuildContext context,
    WidgetRef ref,
    List<MusicRankingItem> items,
    int index,
  ) async {
    final List<PlayableItem> queue = items
        .map((MusicRankingItem item) => item.toPlayableItem())
        .toList(growable: false);

    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queue,
      startIndex: index,
      sourceLabel: '近期音乐榜',
    );
  }
}

class _MusicRankingSplitView extends StatelessWidget {
  const _MusicRankingSplitView({required this.items, required this.onItemTap});

  final List<MusicRankingItem> items;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    final List<_RankingSectionData> sections = _splitIntoSections(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(sections.length, (int index) {
        final _RankingSectionData section = sections[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == sections.length - 1 ? 0 : 18,
          ),
          child: _MusicRankingGroup(
            title: section.title,
            items: section.items,
            startRank: section.startRank,
            onItemTap: (int localIndex) {
              onItemTap(section.startIndex + localIndex);
            },
          ),
        );
      }),
    );
  }

  List<_RankingSectionData> _splitIntoSections(List<MusicRankingItem> items) {
    final List<_RankingSectionData> sections = <_RankingSectionData>[];
    final int baseSize = items.length ~/ MusicRankingSection._sectionCount;
    final int remainder = items.length % MusicRankingSection._sectionCount;

    int start = 0;
    for (int index = 0; index < MusicRankingSection._sectionCount; index++) {
      final int extra = index < remainder ? 1 : 0;
      final int end = start + baseSize + extra;

      if (start >= items.length) {
        break;
      }

      sections.add(
        _RankingSectionData(
          title: index == 0 ? '热榜上半区' : '热榜下半区',
          items: items.sublist(start, end),
          startIndex: start,
          startRank: start + 1,
        ),
      );

      start = end;
    }

    return sections;
  }
}

class _RankingSectionData {
  const _RankingSectionData({
    required this.title,
    required this.items,
    required this.startIndex,
    required this.startRank,
  });

  final String title;
  final List<MusicRankingItem> items;
  final int startIndex;
  final int startRank;
}

class _MusicRankingGroup extends StatelessWidget {
  const _MusicRankingGroup({
    required this.title,
    required this.items,
    required this.startRank,
    required this.onItemTap,
  });

  final String title;
  final List<MusicRankingItem> items;
  final int startRank;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 202,
          child: _MusicRankingPager(
            items: items,
            startRank: startRank,
            onItemTap: onItemTap,
          ),
        ),
      ],
    );
  }
}

class _MusicRankingPager extends StatelessWidget {
  const _MusicRankingPager({
    required this.items,
    required this.startRank,
    required this.onItemTap,
  });

  final List<MusicRankingItem> items;
  final int startRank;
  final ValueChanged<int> onItemTap;

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
                    startRank:
                        startRank + index * MusicRankingSection._columnSize,
                    onItemTap: (int localIndex) {
                      onItemTap(
                        index * MusicRankingSection._columnSize + localIndex,
                      );
                    },
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
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 18,
                      width: 188,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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
  const _MusicRankingError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
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
  const _MusicRankingColumn({
    required this.items,
    required this.startRank,
    required this.onItemTap,
  });

  final List<MusicRankingItem> items;
  final int startRank;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 14),
          child: _MusicRankingTile(
            item: items[index],
            rank: startRank + index,
            onTap: () => onItemTap(index),
          ),
        );
      }),
    );
  }
}

class _MusicRankingTile extends StatelessWidget {
  const _MusicRankingTile({
    required this.item,
    required this.rank,
    required this.onTap,
  });

  final MusicRankingItem item;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: <Widget>[
              _RankingCover(item: item, rank: rank, size: 50),
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
        ),
      ),
    );
  }
}

class _RankingCover extends StatelessWidget {
  const _RankingCover({required this.item, required this.rank, this.size = 44});

  final MusicRankingItem item;
  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CommonCachedImage(
        imageUrl: item.coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallbackIcon: Icons.music_note_rounded,
        iconColor: const Color(0xFF64748B),
        backgroundColor: const Color(0xFFDDE6F2),
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
