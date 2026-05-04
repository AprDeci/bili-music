import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/common/components/url_text_input.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/meting/logic/meting_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_audio_quality_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerSettingsPage extends ConsumerStatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  ConsumerState<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends ConsumerState<PlayerSettingsPage> {
  late String _metingBaseUrlValue;
  bool _isSavingMetingBaseUrl = false;

  @override
  void initState() {
    super.initState();
    _metingBaseUrlValue = ref.read(metingSettingsLogicProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);
    final PlayerAudioQualityPreference audioQualityPreference = ref.watch(
      playerAudioQualityPreferenceLogicProvider,
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
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.lyrics_outlined),
              title: const Text('Meting API 接口地址'),
              subtitle: Text(
                ref.watch(metingSettingsLogicProvider).isEmpty
                    ? '未配置歌词查询服务'
                    : ref.watch(metingSettingsLogicProvider),
                style: theme.textTheme.bodySmall,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      UrlTextInput(
                        labelText: '服务地址',
                        hintText: 'https://meting.example.com/api',
                        value: _metingBaseUrlValue,
                        enabled: !_isSavingMetingBaseUrl,
                        onChanged: (String value) {
                          _metingBaseUrlValue = value;
                        },
                        onSubmitted: (_) => _handleSaveMetingBaseUrl(),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: _isSavingMetingBaseUrl
                                ? null
                                : _handleSaveMetingBaseUrl,
                            icon: _isSavingMetingBaseUrl
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              _isSavingMetingBaseUrl ? '保存中...' : '保存地址',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isSavingMetingBaseUrl
                                ? null
                                : _handleClearMetingBaseUrl,
                            icon: const Icon(Icons.clear_rounded),
                            label: const Text('清空'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveMetingBaseUrl() async {
    final String value = normalizeHttpUrl(_metingBaseUrlValue);
    if (!isValidHttpUrl(value)) {
      ToastUtil.show('请输入有效的 http 或 https 地址');
      return;
    }

    setState(() {
      _isSavingMetingBaseUrl = true;
    });

    try {
      await ref.read(metingSettingsLogicProvider.notifier).setBaseUrl(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _metingBaseUrlValue = ref.read(metingSettingsLogicProvider);
      });
      ToastUtil.show(
        value.isEmpty ? '已清空 Meting API 接口地址' : 'Meting API 接口地址已保存',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMetingBaseUrl = false;
        });
      }
    }
  }

  Future<void> _handleClearMetingBaseUrl() async {
    setState(() {
      _metingBaseUrlValue = '';
    });
    await _handleSaveMetingBaseUrl();
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
