import 'package:flutter/material.dart';

class CommonSearchBar extends StatelessWidget {
  const CommonSearchBar({
    super.key,
    this.onTap,
    this.hintText = '',
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  final VoidCallback? onTap;
  final String hintText;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
