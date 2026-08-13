import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLyricOffsetSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (BuildContext context) {
      return const _LyricOffsetSheet();
    },
  );
}

class _LyricOffsetSheet extends ConsumerWidget {
  const _LyricOffsetSheet();

  static const int _stepMs = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MetadataState metadataState = ref.watch(metadataControllerProvider);
    final MetadataController controller = ref.read(
      metadataControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                tooltip: '歌词延后 0.5 秒',
                onPressed: () => controller.adjustOffset(-_stepMs),
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 96,
                child: Center(
                  child: Text(
                    _formatOffset(
                      resolveDisplayLyricOffsetMs(metadataState.metadata),
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: '歌词提前 0.5 秒',
                onPressed: () => controller.adjustOffset(_stepMs),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatOffset(int offsetMs) {
  final double seconds = offsetMs / Duration.millisecondsPerSecond;
  if (offsetMs > 0) {
    return '+${seconds.toStringAsFixed(1)}s';
  }
  return '${seconds.toStringAsFixed(1)}s';
}
