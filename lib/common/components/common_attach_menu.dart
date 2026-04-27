import 'package:bilimusic/common/components/icon_and_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CommonAttachMenuItem<T> {
  const CommonAttachMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.selected = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Object icon;
  final bool selected;
  final bool enabled;
}

class CommonAttachMenu<T> extends StatelessWidget {
  const CommonAttachMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.itemHeight = 44,
    this.showDividers = true,
  });

  final List<CommonAttachMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final double itemHeight;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < items.length; index++) ...<Widget>[
          _CommonAttachMenuTile<T>(
            item: items[index],
            height: itemHeight,
            onSelected: onSelected,
          ),
          if (showDividers && index != items.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
        ],
      ],
    );
  }
}

class _CommonAttachMenuTile<T> extends StatefulWidget {
  const _CommonAttachMenuTile({
    required this.item,
    required this.height,
    required this.onSelected,
  });

  final CommonAttachMenuItem<T> item;
  final double height;
  final ValueChanged<T> onSelected;

  @override
  State<_CommonAttachMenuTile<T>> createState() =>
      _CommonAttachMenuTileState<T>();
}

class _CommonAttachMenuTileState<T> extends State<_CommonAttachMenuTile<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final CommonAttachMenuItem<T> item = widget.item;
    final bool enabled = item.enabled;
    final Color foregroundColor = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.28)
        : item.selected
        ? colorScheme.primary
        : colorScheme.onSurface;
    final Color backgroundColor = _isHovered && enabled
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
        : Colors.transparent;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: enabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                widget.onSelected(item.value);
                SmartDialog.dismiss<void>();
              }
            : null,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: backgroundColor,
          child: Row(
            children: <Widget>[
              IconAndWidget(icon: item.icon, size: 19, color: foregroundColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: item.selected ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (item.selected) ...<Widget>[
                const SizedBox(width: 8),
                Icon(Icons.check_rounded, size: 17, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
