import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showCarPlayerQueuePanel({required BuildContext context}) =>
    showCarSidePanel<void>(
      context: context,
      builder: (_) => const CarPlayerQueueContent(),
    );

class CarPlayerQueueContent extends ConsumerWidget {
  const CarPlayerQueueContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              IconButton.filledTonal(
                tooltip: '关闭播放队列',
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  '播放队列 · ${state.queue.length} 首',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: !state.hasQueue
              ? const Center(child: Text('播放队列为空'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: state.queue.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = state.queue[index];
                    final display = ref
                        .watch(playerQueueDisplayProvider(item))
                        .asData
                        ?.value;
                    final bool current = state.currentQueueIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minTileHeight: 88,
                        selected: current,
                        selectedTileColor: colors.primaryContainer,
                        selectedColor: colors.onPrimaryContainer,
                        leading: SizedBox(
                          width: 32,
                          child: current
                              ? Icon(
                                  Icons.graphic_eq_rounded,
                                  color: colors.primary,
                                )
                              : Text(
                                  '${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium,
                                ),
                        ),
                        title: Text(
                          display?.title ?? item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: current ? colors.onPrimaryContainer : null,
                          ),
                        ),
                        subtitle: Text(
                          display?.artist ?? item.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: current
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.skipToQueueIndex(index);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
