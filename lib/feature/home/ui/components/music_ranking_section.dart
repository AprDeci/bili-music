import 'dart:math' as math;

import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class MusicRankingSection extends ConsumerWidget {
  const MusicRankingSection({super.key});

  static const int _columnSize = 3;
  static const int _desktopPageColumns = 2;
  static const int _desktopPageSize = _columnSize * _desktopPageColumns;
  static const int _sectionCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
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
              color: colorScheme.onSurface,
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (PlatformUtil.isDesktop) {
          return SizedBox(
            height: 202,
            child: _MusicRankingDesktopPager(
              items: items,
              startRank: 1,
              onItemTap: onItemTap,
            ),
          );
        }

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
      },
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
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurfaceVariant,
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
        if (PlatformUtil.isDesktop) {
          return _MusicRankingDesktopPager(
            items: items,
            startRank: startRank,
            onItemTap: onItemTap,
          );
        }

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

class _MusicRankingDesktopPager extends StatefulWidget {
  const _MusicRankingDesktopPager({
    required this.items,
    required this.startRank,
    required this.onItemTap,
  });

  final List<MusicRankingItem> items;
  final int startRank;
  final ValueChanged<int> onItemTap;

  @override
  State<_MusicRankingDesktopPager> createState() =>
      _MusicRankingDesktopPagerState();
}

class _MusicRankingDesktopPagerState extends State<_MusicRankingDesktopPager> {
  late final PageController _pageController;
  bool _isHovering = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<List<List<MusicRankingItem>>> pages = _buildPages(widget.items);
    if (pages.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool canPage = pages.length > 1;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (BuildContext context, int pageIndex) {
              return _MusicRankingPageGrid(
                columns: pages[pageIndex],
                pageStartIndex:
                    pageIndex * MusicRankingSection._desktopPageSize,
                startRank: widget.startRank,
                onItemTap: widget.onItemTap,
              );
            },
          ),
          if (canPage) ...<Widget>[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: !_isHovering,
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: BarIconButton(
                      icon: Icons.chevron_left_rounded,
                      width: 34,
                      height: 72,
                      iconSize: 34,
                      onPressed: () => _goPrevious(pages.length),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: !_isHovering,
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: BarIconButton(
                      icon: Icons.chevron_right_rounded,
                      width: 34,
                      height: 72,
                      iconSize: 34,
                      onPressed: () => _goNext(pages.length),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<List<List<MusicRankingItem>>> _buildPages(List<MusicRankingItem> items) {
    final List<List<List<MusicRankingItem>>> pages =
        <List<List<MusicRankingItem>>>[];

    for (
      int pageStart = 0;
      pageStart < items.length;
      pageStart += MusicRankingSection._desktopPageSize
    ) {
      final int pageEnd = math.min(
        pageStart + MusicRankingSection._desktopPageSize,
        items.length,
      );
      final List<List<MusicRankingItem>> columns = <List<MusicRankingItem>>[];

      for (
        int columnStart = pageStart;
        columnStart < pageEnd;
        columnStart += MusicRankingSection._columnSize
      ) {
        final int columnEnd = math.min(
          columnStart + MusicRankingSection._columnSize,
          pageEnd,
        );
        columns.add(items.sublist(columnStart, columnEnd));
      }

      pages.add(columns);
    }

    return pages;
  }

  void _goPrevious(int pageCount) {
    final int targetPage = _currentPage == 0 ? pageCount - 1 : _currentPage - 1;
    _animateToPage(targetPage);
  }

  void _goNext(int pageCount) {
    final int targetPage = _currentPage == pageCount - 1 ? 0 : _currentPage + 1;
    _animateToPage(targetPage);
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MusicRankingPageGrid extends StatelessWidget {
  const _MusicRankingPageGrid({
    required this.columns,
    required this.pageStartIndex,
    required this.startRank,
    required this.onItemTap,
  });

  final List<List<MusicRankingItem>> columns;
  final int pageStartIndex;
  final int startRank;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    for (
      int index = 0;
      index < MusicRankingSection._desktopPageColumns;
      index++
    ) {
      if (index > 0) {
        children.add(const SizedBox(width: 30));
      }

      if (index >= columns.length) {
        children.add(const Expanded(child: SizedBox.shrink()));
        continue;
      }

      children.add(
        Expanded(
          child: _MusicRankingColumn(
            items: columns[index],
            startRank:
                startRank +
                pageStartIndex +
                index * MusicRankingSection._columnSize,
            onItemTap: (int localIndex) {
              onItemTap(
                pageStartIndex +
                    index * MusicRankingSection._columnSize +
                    localIndex,
              );
            },
          ),
        ),
      );
    }

    return Row(children: children);
  }
}

class _MusicRankingLoading extends StatelessWidget {
  const _MusicRankingLoading();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (PlatformUtil.isDesktop) {
          return const SizedBox(
            height: 202,
            child: Row(
              children: <Widget>[
                Expanded(child: _MusicRankingLoadingColumn()),
                SizedBox(width: 30),
                Expanded(child: _MusicRankingLoadingColumn()),
                SizedBox(width: 30),
                Expanded(child: _MusicRankingLoadingColumn()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(2, (int index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index == 1 ? 0 : 18),
              child: const _MusicRankingLoadingGroup(),
            );
          }),
        );
      },
    );
  }
}

class _MusicRankingLoadingGroup extends StatelessWidget {
  const _MusicRankingLoadingGroup();

  static const Color _placeholderColor = Color(0xFFDDE6F2);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 92,
          height: 16,
          decoration: BoxDecoration(
            color: _placeholderColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 202,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (PlatformUtil.isDesktop) {
                return const Row(
                  children: <Widget>[
                    Expanded(child: _MusicRankingLoadingColumn()),
                    SizedBox(width: 30),
                    Expanded(child: _MusicRankingLoadingColumn()),
                    SizedBox(width: 30),
                    Expanded(child: _MusicRankingLoadingColumn()),
                  ],
                );
              }

              final double pageWidth = math.min(
                constraints.maxWidth * 0.9,
                620,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: pageWidth,
                      child: const _MusicRankingLoadingColumn(),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: pageWidth,
                      child: const _MusicRankingLoadingColumn(itemCount: 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MusicRankingLoadingColumn extends StatelessWidget {
  const _MusicRankingLoadingColumn({this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(itemCount, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 14),
          child: const _MusicRankingLoadingTile(),
        );
      }),
    );
  }
}

class _MusicRankingLoadingTile extends StatelessWidget {
  const _MusicRankingLoadingTile();

  static const Color _placeholderColor = Color(0xFFDDE6F2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _placeholderColor,
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
                    color: _placeholderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _placeholderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: _placeholderColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _placeholderColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicRankingError extends StatelessWidget {
  const _MusicRankingError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              size: 34,
              color: colorScheme.onSurfaceVariant,
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
                color: colorScheme.onSurfaceVariant,
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
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Text(
        '暂无热榜内容',
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
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
    final ColorScheme colorScheme = theme.colorScheme;

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
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -1.4,
                        color: colorScheme.onSurface,
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
                              color: colorScheme.onSurfaceVariant,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CommonCachedImage(
        imageUrl: item.coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallbackIcon: Icons.music_note_rounded,
        iconColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surfaceContainerHighest,
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
