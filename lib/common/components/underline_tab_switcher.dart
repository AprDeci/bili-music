import 'package:flutter/material.dart';

class UnderlineTabSwitcher extends StatelessWidget {
  const UnderlineTabSwitcher({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.minimumSize = const Size(64, 36),
    this.textStyle,
    this.spacing = 28,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Size minimumSize;
  final TextStyle? textStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing,
        children: List<Widget>.generate(labels.length, (int index) {
          final bool selected = index == selectedIndex;
          final Color color = selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant;
          return MergeSemantics(
            child: Semantics(
              selected: selected,
              child: TextButton(
                onPressed: () => onChanged(index),
                style: TextButton.styleFrom(
                  minimumSize: minimumSize,
                  foregroundColor: color,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  shape: const RoundedRectangleBorder(),
                  textStyle: (textStyle ?? theme.textTheme.titleSmall)
                      ?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(labels[index]),
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
