import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_parts_list.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showCarPlayerQueuePanel({required BuildContext context}) =>
    showCarSidePanel<void>(
      context: context,
      builder: (_) => const CarPlayerQueueContent(),
    );

enum _CarQueueTab { queue, parts }

class CarPlayerQueueContent extends ConsumerStatefulWidget {
  const CarPlayerQueueContent({super.key});

  @override
  ConsumerState<CarPlayerQueueContent> createState() =>
      _CarPlayerQueueContentState();
}

class _CarPlayerQueueContentState extends ConsumerState<CarPlayerQueueContent> {
  _CarQueueTab _tab = _CarQueueTab.queue;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final bool hasParts = state.availableParts.length > 1;
    final _CarQueueTab tab = hasParts ? _tab : _CarQueueTab.queue;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: <Widget>[
              IconButton.filledTonal(
                tooltip: '关闭',
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: SegmentedButton<_CarQueueTab>(
                  segments: <ButtonSegment<_CarQueueTab>>[
                    ButtonSegment<_CarQueueTab>(
                      value: _CarQueueTab.queue,
                      label: Text('播放队列'),
                      icon: const Icon(Icons.queue_music_rounded),
                      enabled: true,
                    ),
                    ButtonSegment<_CarQueueTab>(
                      value: _CarQueueTab.parts,
                      label: Text('分P'),
                      icon: const Icon(Icons.playlist_play_rounded),
                      enabled: hasParts,
                    ),
                  ],
                  selected: <_CarQueueTab>{tab},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    minimumSize: const WidgetStatePropertyAll<Size>(
                      Size(0, 56),
                    ),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textStyle: WidgetStatePropertyAll<TextStyle?>(
                      theme.textTheme.titleMedium,
                    ),
                  ),
                  onSelectionChanged: (Set<_CarQueueTab> selection) =>
                      setState(() => _tab = selection.first),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Material(
            color: theme.colorScheme.surface,
            clipBehavior: Clip.hardEdge,
            child: switch (tab) {
              _CarQueueTab.queue => PlayerQueueList(
                state: state,
                controller: controller,
                isCar: true,
                onClose: () async => Navigator.of(context).pop(),
              ),
              _CarQueueTab.parts => PlayerPartsList(
                parts: state.availableParts,
                currentItem: state.currentItem,
                state: state,
                controller: controller,
                isCar: true,
                onClose: () async => Navigator.of(context).pop(),
              ),
            },
          ),
        ),
      ],
    );
  }
}
