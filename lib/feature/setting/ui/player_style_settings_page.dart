import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:bilimusic/feature/player/logic/player_ui_style_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerStyleSettingsPage extends ConsumerWidget {
  const PlayerStyleSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerUiStyle selected = ref.watch(playerUiStyleLogicProvider);
    final ColorScheme colors = Theme.of(context).colorScheme;

    void select(PlayerUiStyle? style) {
      if (style != null && style != selected) {
        ref.read(playerUiStyleLogicProvider.notifier).setStyle(style);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('播放器风格')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: RadioGroup<PlayerUiStyle>(
            groupValue: selected,
            onChanged: select,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                const double spacing = 24;
                final int columns = (constraints.maxWidth / 240).ceil();
                final double width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 24,
                  children: <Widget>[
                    for (final PlayerUiStyle style in PlayerUiStyle.values)
                      SizedBox(
                        width: width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Semantics(
                              label: '选择${style.title}风格',
                              selected: style == selected,
                              child: Material(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => select(style),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: style == selected
                                            ? colors.primary
                                            : colors.outlineVariant,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AspectRatio(
                                        aspectRatio: 393 / 853,
                                        child: Image.asset(
                                          'assets/player_styles/${style.storageValue}.webp',
                                          fit: BoxFit.cover,
                                          excludeFromSemantics: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<PlayerUiStyle>(
                              value: style,
                              title: Text(style.title),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              selected: style == selected,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
