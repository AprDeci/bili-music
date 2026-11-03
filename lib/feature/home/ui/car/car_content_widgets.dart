import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarContentHeader extends StatelessWidget {
  const CarContentHeader({
    super.key,
    required this.title,
    this.backLocation,
    this.action,
  });

  final String title;
  final String? backLocation;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: <Widget>[
          if (backLocation != null) ...<Widget>[
            IconButton.filledTonal(
              tooltip: '返回',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(backLocation!);
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class CarContentCard extends StatelessWidget {
  const CarContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.coverUrl,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              CommonCachedImage(
                imageUrl: coverUrl,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(18),
                fallbackIcon: icon,
                iconSize: 30,
                iconColor: colors.onSurfaceVariant,
                backgroundColor: colors.surfaceContainerLow,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarSongList extends ConsumerWidget {
  const CarSongList({
    super.key,
    required this.items,
    required this.sourceLabel,
    this.emptyTitle = '这里还没有歌曲',
    this.emptyDescription = '喜欢的内容会出现在这里。',
  });

  final List<PlayableItem> items;
  final String sourceLabel;
  final String emptyTitle;
  final String emptyDescription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverStatusView(
            child: StatusView(
              title: emptyTitle,
              description: emptyDescription,
              icon: Icons.music_note_rounded,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: () => _play(context, ref, 0),
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: Text('播放全部 · ${items.length}'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => CarSongTile(
              item: items[index],
              index: index,
              onTap: () => _play(context, ref, index),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref, int index) async {
    try {
      await PlayerUtil.playQueueAndOpenPlayer(
        context,
        ref,
        items: items,
        startIndex: index,
        sourceLabel: sourceLabel,
      );
    } on Object {
      if (context.mounted) {
        ToastUtil.show('播放失败，请重试');
      }
    }
  }
}

class CarSongTile extends ConsumerWidget {
  const CarSongTile({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
  });

  final PlayableItem item;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool current = ref.watch(
      playerControllerProvider.select(
        (state) => state.currentItem?.contentId == item.contentId,
      ),
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: current ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          selected: current,
          button: true,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 32,
                    child: current
                        ? Icon(Icons.equalizer_rounded, color: colors.primary)
                        : Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                  ),
                  const SizedBox(width: 12),
                  CommonCachedImage(
                    imageUrl: item.coverUrl,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(14),
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colors.onSurfaceVariant,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: current ? colors.onPrimaryContainer : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          <String>[
                            if (item.author.isNotEmpty) item.author,
                            if (item.pageTitle?.trim().isNotEmpty ?? false)
                              item.pageTitle!,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: current
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: current ? colors.primary : colors.onSurfaceVariant,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
