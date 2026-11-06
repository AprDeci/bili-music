import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ThemeUiModel themeState = ref.watch(themeLogicProvider);
    final bool carUi = ref.watch(carUiSettingLogicProvider);
    final bool useCarLayout = AppLayoutScope.of(context) == AppLayout.car;
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('外观设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          if (!AppLayout.isDesktopPlatform) ...[
            SwitchListTile.adaptive(
              title: const Text('启用车机 UI'),
              subtitle: const Text('横屏使用常驻播放区与大按钮，竖屏使用移动端布局'),
              secondary: const Icon(Icons.directions_car_rounded),
              value: carUi,
              onChanged: (bool value) async {
                try {
                  await ref
                      .read(carUiSettingLogicProvider.notifier)
                      .setEnabled(value);
                } on Object {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('车机 UI 设置保存失败，请重试')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
          if (!useCarLayout && !AppLayout.isDesktopPlatform)
            SwitchListTile.adaptive(
              title: const Text('启用玻璃导航栏/播放栏'),
              value: useGlassBar,
              onChanged: (bool value) async {
                await ref
                    .read(appearanceSettingLogicProvider.notifier)
                    .setUseGlassBar(value);
              },
            ),
          Text('主题模式', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: RadioGroup(
              onChanged: (ThemeMode? value) {
                if (value == null) {
                  return;
                }
                ref.read(themeLogicProvider.notifier).setThemeMode(value);
              },
              groupValue: themeState.themeMode,
              child: Column(
                children: ThemeMode.values
                    .map((ThemeMode mode) {
                      return RadioListTile<ThemeMode>(
                        value: mode,
                        title: Text(_themeModeLabel(mode)),
                        subtitle: Text(_themeModeDescription(mode)),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
          if (!useCarLayout) ...<Widget>[
            const SizedBox(height: 24),
            Text('主题颜色', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: RadioGroup(
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  ref.read(themeLogicProvider.notifier).setThemeVariant(value);
                },
                groupValue: themeState.themeVariantId,
                child: Column(
                  children: themeCatalog
                      .map((ThemeDefinition definition) {
                        return RadioListTile<String>(
                          value: definition.id,
                          title: Text(definition.label),
                          subtitle: Text(definition.description),
                          secondary: _ThemePreviewDot(
                            color: definition.seedColor,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }

  String _themeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '根据系统当前的明暗模式自动切换';
      case ThemeMode.light:
        return '始终使用浅色外观';
      case ThemeMode.dark:
        return '始终使用深色外观';
    }
  }
}

class _ThemePreviewDot extends StatelessWidget {
  const _ThemePreviewDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
