import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';

Future<void> showPlayerPartSelector({
  required BuildContext context,
  required List<PlayableItem> parts,
  required PlayableItem currentItem,
  required PlayerState state,
  required PlayerController controller,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return _PlayerPartSelectorSheet(
        parts: parts,
        currentItem: currentItem,
        state: state,
        controller: controller,
      );
    },
  );
}

class _PlayerPartSelectorSheet extends StatelessWidget {
  const _PlayerPartSelectorSheet({
    required this.parts,
    required this.currentItem,
    required this.state,
    required this.controller,
  });

  final List<PlayableItem> parts;
  final PlayableItem currentItem;
  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Set<String> queuedIds = state.queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    final List<PlayableItem> partsToEnqueue = parts
        .where((PlayableItem part) => part != currentItem)
        .where((PlayableItem part) => !queuedIds.contains(part.stableId))
        .toList();

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: parts.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              tileColor: colorScheme.primary.withValues(alpha: 0.08),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.queue_music_rounded),
              ),
              title: Text(
                '全部加入队列',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                partsToEnqueue.isEmpty
                    ? '其余分P已全部在队列中'
                    : '将 ${partsToEnqueue.length} 个其余分P追加到当前队列',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              trailing: const Icon(Icons.add_rounded),
              onTap: partsToEnqueue.isEmpty
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await controller.enqueue(partsToEnqueue);
                      if (!context.mounted) {
                        return;
                      }
                      ToastUtil.show('已将 ${partsToEnqueue.length} 个分P加入队列');
                    },
            );
          }

          final PlayableItem part = parts[index - 1];
          final bool isSelected = part == currentItem;
          final String title = part.pageTitle?.trim() ?? '';
          final int page = part.page ?? index;
          final String label = title.isEmpty ? 'P$page' : 'P$page · $title';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            tileColor: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
              child: Text('P$page'),
            ),
            title: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: colorScheme.primary)
                : const Icon(Icons.play_arrow_rounded),
            onTap: () {
              Navigator.of(context).pop();
              if (part != currentItem) {
                controller.replaceCurrentQueueItem(part);
              }
            },
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 10),
      ),
    );
  }
}
