import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:bilimusic/feature/setting/logic/hotkey_settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeySettingsPage extends ConsumerWidget {
  const HotkeySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final List<HotkeyBinding> bindings = ref.watch(hotkeySettingsLogicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('快捷键设置'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await ref
                  .read(hotkeySettingsLogicProvider.notifier)
                  .resetDefaults();
              ToastUtil.show('已恢复默认快捷键');
            },
            child: const Text('恢复默认'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(
            '快捷键在桌面端全局生效。若某个组合键已被系统或其他应用占用，请更换后保存。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final HotkeyAction action in HotkeyAction.values)
            _HotkeyTile(
              binding: bindings.firstWhere(
                (HotkeyBinding binding) => binding.action == action,
              ),
            ),
        ],
      ),
    );
  }
}

class _HotkeyTile extends ConsumerWidget {
  const _HotkeyTile({required this.binding});

  final HotkeyBinding binding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final HotKey? hotKey = binding.toHotKey();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(binding.action.title),
        subtitle: Text(
          binding.action.description,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (binding.enabled && hotKey != null)
              HotKeyVirtualView(hotKey: hotKey)
            else
              Text('未启用', style: theme.textTheme.bodySmall),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () => _showHotkeySheet(context, ref, binding),
      ),
    );
  }
}

Future<void> _showHotkeySheet(
  BuildContext context,
  WidgetRef ref,
  HotkeyBinding binding,
) async {
  HotKey? recordedHotKey = binding.toHotKey();

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      final ThemeData theme = Theme.of(context);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(binding.action.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('按下新的组合键后会自动记录，点击保存后生效。', style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.keyboard_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HotKeyRecorder(
                          initalHotKey: recordedHotKey,
                          onHotKeyRecorded: (HotKey hotKey) {
                            recordedHotKey = hotKey;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(hotkeySettingsLogicProvider.notifier)
                          .setBinding(binding.copyWith(enabled: false));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.block_rounded),
                    label: const Text('禁用'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      final HotKey? hotKey = recordedHotKey;
                      if (hotKey == null) {
                        ToastUtil.show('请先按下一个快捷键');
                        return;
                      }
                      await ref
                          .read(hotkeySettingsLogicProvider.notifier)
                          .setBinding(
                            HotkeyBinding.fromHotKey(
                              action: binding.action,
                              hotKey: hotKey,
                            ),
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
