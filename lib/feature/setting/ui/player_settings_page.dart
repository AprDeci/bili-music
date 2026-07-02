import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/domain/multi_part_queue_preference.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_preference.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_size_preference.dart';
import 'package:bilimusic/feature/player/logic/player_audio_quality_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_font_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_font_size_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_multi_part_queue_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerSettingsPage extends ConsumerWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);
    final PlayerAudioQualityPreference audioQualityPreference = ref.watch(
      playerAudioQualityPreferenceLogicProvider,
    );
    final MultiPartQueuePreference multiPartQueuePreference = ref.watch(
      playerMultiPartQueuePreferenceLogicProvider,
    );
    final PlayerLyricFontPreference lyricFontPreference = ref.watch(
      playerLyricFontPreferenceLogicProvider,
    );
    final PlayerLyricFontSizePreference lyricFontSizePreference = ref.watch(
      playerLyricFontSizePreferenceLogicProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('播放器设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          PlatformUtil.isMobile
              ? SwitchListTile.adaptive(
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
                )
              : Container(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.graphic_eq_rounded),
            title: const Text('默认音质'),
            subtitle: Text(
              audioQualityPreference.title,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAudioQualitySheet(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.video_collection_rounded),
            title: const Text('分段视频默认添加方式'),
            subtitle: Text(
              multiPartQueuePreference.title,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showMultiPartPreferenceSheet(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lyrics_rounded),
            title: const Text('歌词字体'),
            subtitle: Text(
              lyricFontPreference.title,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLyricFontPreferenceSheet(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('歌词字号'),
            subtitle: Text(
              lyricFontSizePreference.title,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLyricFontSizePreferenceSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLyricFontPreferenceSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final ThemeData theme = Theme.of(context);
  final PlayerLyricFontPreference currentPreference = ref.read(
    playerLyricFontPreferenceLogicProvider,
  );
  const List<PlayerLyricFontPreference> preferences =
      <PlayerLyricFontPreference>[
        PlayerLyricFontPreference.appDefault,
        PlayerLyricFontPreference.microsoftYaHei,
        PlayerLyricFontPreference.simSun,
        PlayerLyricFontPreference.kaiTi,
        PlayerLyricFontPreference.simHei,
        PlayerLyricFontPreference.monospace,
      ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: preferences.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final PlayerLyricFontPreference preference = preferences[index];
            final bool isSelected = preference == currentPreference;
            return ListTile(
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(preference.title),
              subtitle: Text(preference.description),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerLyricFontPreferenceLogicProvider.notifier)
                    .setPreference(preference);
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> _showLyricFontSizePreferenceSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final ThemeData theme = Theme.of(context);
  final PlayerLyricFontSizePreference currentPreference = ref.read(
    playerLyricFontSizePreferenceLogicProvider,
  );
  const List<PlayerLyricFontSizePreference> preferences =
      <PlayerLyricFontSizePreference>[
        PlayerLyricFontSizePreference.small,
        PlayerLyricFontSizePreference.normal,
        PlayerLyricFontSizePreference.large,
        PlayerLyricFontSizePreference.extraLarge,
      ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: preferences.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final PlayerLyricFontSizePreference preference = preferences[index];
            final bool isSelected = preference == currentPreference;
            return ListTile(
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(preference.title),
              subtitle: Text(preference.description),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerLyricFontSizePreferenceLogicProvider.notifier)
                    .setPreference(preference);
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> _showAudioQualitySheet(BuildContext context, WidgetRef ref) async {
  final ThemeData theme = Theme.of(context);
  final PlayerAudioQualityPreference currentPreference = ref.read(
    playerAudioQualityPreferenceLogicProvider,
  );
  const List<PlayerAudioQualityPreference> preferences =
      <PlayerAudioQualityPreference>[
        PlayerAudioQualityPreference.auto,
        PlayerAudioQualityPreference.hires,
        PlayerAudioQualityPreference.k192,
        PlayerAudioQualityPreference.k132,
      ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: preferences.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final PlayerAudioQualityPreference preference = preferences[index];
            final bool isSelected = preference == currentPreference;
            return ListTile(
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(preference.title),
              subtitle: Text(preference.description),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerControllerProvider.notifier)
                    .setAudioQualityPreference(preference);
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> _showMultiPartPreferenceSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final ThemeData theme = Theme.of(context);
  final MultiPartQueuePreference currentPreference = ref.read(
    playerMultiPartQueuePreferenceLogicProvider,
  );
  const List<MultiPartQueuePreference> preferences = <MultiPartQueuePreference>[
    MultiPartQueuePreference.currentPart,
    MultiPartQueuePreference.allParts,
  ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: preferences.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final MultiPartQueuePreference preference = preferences[index];
            final bool isSelected = preference == currentPreference;
            return ListTile(
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(preference.title),
              subtitle: Text(preference.description),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerMultiPartQueuePreferenceLogicProvider.notifier)
                    .setPreference(preference);
              },
            );
          },
        ),
      );
    },
  );
}
