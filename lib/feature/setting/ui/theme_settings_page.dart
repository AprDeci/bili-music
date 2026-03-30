import 'package:bilimusic/core/theme/light_theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ThemeUiModel themeState = ref.watch(themeLogicProvider);
    final List<LightThemeDefinition> lightThemes = LightThemeVariant.values
        .map(lightThemeDefinitionOf)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text('主题模式', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: ThemeMode.values
                  .map((ThemeMode mode) {
                    return RadioListTile<ThemeMode>(
                      value: mode,
                      groupValue: themeState.themeMode,
                      title: Text(_themeModeLabel(mode)),
                      subtitle: Text(_themeModeDescription(mode)),
                      onChanged: (ThemeMode? value) {
                        if (value == null) {
                          return;
                        }
                        ref
                            .read(themeLogicProvider.notifier)
                            .setThemeMode(value);
                      },
                    );
                  })
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 24),
          Text('浅色主题选择', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            themeState.themeMode == ThemeMode.light
                ? '当前选择会立即应用。'
                : '当前选择会在切换到浅色模式后生效。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: LightThemeVariant.values
                  .map((LightThemeVariant variant) {
                    final LightThemeDefinition definition =
                        lightThemeDefinitionOf(variant);

                    return RadioListTile<LightThemeVariant>(
                      value: variant,
                      groupValue: themeState.lightThemeVariant,
                      title: Text(definition.label),
                      subtitle: Text(definition.description),
                      secondary: _ThemePreviewDot(
                        color: definition.seedColor,
                      ),
                      onChanged: (LightThemeVariant? value) {
                        if (value == null) {
                          return;
                        }
                        ref
                            .read(themeLogicProvider.notifier)
                            .setLightThemeVariant(value);
                      },
                    );
                  })
                  .toList(growable: false),
            ),
          ),
          if (lightThemes.length == 1) ...<Widget>[
            const SizedBox(height: 10),
            Text('后续新增配色时，只需要扩展主题定义即可。', style: theme.textTheme.bodySmall),
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
