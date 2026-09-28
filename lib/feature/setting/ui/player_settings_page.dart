import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_preference.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/meting/ui/meting_source_rule_dialog.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/logic/player_audio_quality_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerSettingsPage extends ConsumerWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);
    final bool useMetadataCover = ref.watch(playerCoverSettingsLogicProvider);
    final PlayerAudioQualityPreference audioQualityPreference = ref.watch(
      playerAudioQualityPreferenceLogicProvider,
    );
    final MetingSourcePreference sourcePreference = ref.watch(
      metingSourcePreferenceLogicProvider,
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
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const HugeIcon(icon: HugeIcons.strokeRoundedScanImage),
            title: const Text('自动使用元信息封面'),
            subtitle: Text(
              '优先显示歌词与歌曲元信息中的专辑封面',
              style: theme.textTheme.bodySmall,
            ),
            value: useMetadataCover,
            onChanged: (bool value) async {
              await ref
                  .read(playerCoverSettingsLogicProvider.notifier)
                  .setUseMetadataCover(value);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedAudioWave01),
            title: const Text('默认音质'),
            subtitle: Text(
              audioQualityPreference.title,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAudioQualitySheet(context, ref),
          ),
          const Divider(height: 32),
          Text('歌词源', style: theme.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('默认音源'),
            subtitle: Text(
              sourcePreference.defaultServer.label,
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showDefaultServerSheet(
              context,
              ref,
              sourcePreference.defaultServer,
            ),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('关键词规则'),
            children: <Widget>[
              if (sourcePreference.rules.isEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('暂无规则'),
                  subtitle: Text(
                    '播放时在歌词搜索里点「记住关键词音源」即可添加',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              for (final MetingSourceRule rule in sourcePreference.rules)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(rule.keyword),
                  subtitle: Text(rule.server.label),
                  trailing: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    tooltip: '删除',
                    onPressed: () => ref
                        .read(metingSourcePreferenceLogicProvider.notifier)
                        .removeRule(rule),
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_rounded),
                title: const Text('新增规则'),
                onTap: () => _addRule(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

Future<void> _showDefaultServerSheet(
  BuildContext context,
  WidgetRef ref,
  MetingServer currentServer,
) async {
  final ThemeData theme = Theme.of(context);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          shrinkWrap: true,
          children: <Widget>[
            for (final MetingServer server in MetingServer.values)
              ListTile(
                tileColor: server == currentServer
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : null,
                title: Text(server.label),
                trailing: server == currentServer
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref
                      .read(metingSourcePreferenceLogicProvider.notifier)
                      .setDefaultServer(server);
                },
              ),
          ],
        ),
      );
    },
  );
}

Future<void> _addRule(BuildContext context, WidgetRef ref) async {
  final MetingSourceRule? rule = await showMetingSourceRuleDialog(
    context: context,
    initialKeyword: '',
    initialServer: ref.read(metingSourcePreferenceLogicProvider).defaultServer,
  );
  if (rule == null) {
    return;
  }

  await ref
      .read(metingSourcePreferenceLogicProvider.notifier)
      .upsertRule(keyword: rule.keyword, server: rule.server);
}
