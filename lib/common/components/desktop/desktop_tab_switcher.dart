import 'package:flutter/material.dart';

class DesktopTabSwitcher extends StatelessWidget {
  const DesktopTabSwitcher({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(22, 16, 22, 8),
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(labels.length * 2 - 1, (int index) {
          if (index.isOdd) {
            return const SizedBox(width: 28);
          }

          final int labelIndex = index ~/ 2;
          final bool selected = labelIndex == selectedIndex;
          final Color color = selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface;

          return SizedBox(
            height: 36,
            child: TextButton(
              onPressed: () => onChanged(labelIndex),
              style: TextButton.styleFrom(
                    foregroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                  ).copyWith(
                    foregroundColor: WidgetStateProperty.all(Colors.blue),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      labels[labelIndex],
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
