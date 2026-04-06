import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerSettingsPage extends ConsumerWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('播放器设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.multitrack_audio_outlined),
            title: const Text('允许与其他应用同时播放'),
            subtitle: Text('重启后生效', style: theme.textTheme.bodySmall),
            value: allowMixWithOthers,
            onChanged: (bool value) async {
              await ref
                  .read(playerSettingsLogicProvider.notifier)
                  .setAllowMixWithOthers(value);
            },
          ),
        ],
      ),
    );
  }
}
