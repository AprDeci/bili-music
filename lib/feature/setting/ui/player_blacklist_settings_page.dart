import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/player_blacklist_entry.dart';
import 'package:bilimusic/feature/player/logic/player_blacklist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerBlacklistSettingsPage extends ConsumerWidget {
  const PlayerBlacklistSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlayerBlacklistEntry> entries = ref.watch(
      playerBlacklistControllerProvider,
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('歌曲黑名单'),
        actions: <Widget>[
          if (entries.isNotEmpty)
            TextButton(
              onPressed: () => _clearAll(context, ref),
              child: const Text('清空'),
            ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.block_rounded,
                      size: 42,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.62,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无黑名单歌曲',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '在播放页屏蔽歌曲后，后续会自动过滤这些歌曲。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final PlayerBlacklistEntry entry = entries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  tileColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: colorScheme.primary,
                    child: const Icon(Icons.music_off_rounded),
                  ),
                  title: Text(
                    entry.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    entry.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: '移出黑名单',
                    onPressed: () => _removeEntry(context, ref, entry),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _removeEntry(
    BuildContext context,
    WidgetRef ref,
    PlayerBlacklistEntry entry,
  ) async {
    await ref
        .read(playerBlacklistControllerProvider.notifier)
        .removeByStableId(entry.stableId);
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已移出黑名单');
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('清空黑名单'),
              content: const Text('清空后，这些歌曲可以重新加入播放队列。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('清空'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    await ref.read(playerBlacklistControllerProvider.notifier).clear();
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已清空黑名单');
  }
}
