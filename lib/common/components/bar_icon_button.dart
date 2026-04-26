import 'package:flutter/material.dart';

class BarIconButton extends StatefulWidget {
  const BarIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize = 20,
    this.isActive = false,
    this.activeColor,
  });

  final VoidCallback? onPressed;
  final Object icon;
  final double iconSize;
  final bool isActive;
  final Color? activeColor;

  @override
  State<BarIconButton> createState() => _BarIconButtonState();
}

class _BarIconButtonState extends State<BarIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isEnabled = widget.onPressed != null;

    final Color iconColor = !isEnabled
        ? colorScheme.onSurface.withValues(alpha: 0.28)
        : widget.isActive
        ? widget.activeColor ?? colorScheme.primary
        : _isHovered
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(child: _buildIcon(iconColor)),
        ),
      ),
    );
  }

  Widget _buildIcon(Color iconColor) {
    final Object icon = widget.icon;

    if (icon is IconData) {
      return Icon(icon, size: widget.iconSize, color: iconColor);
    }

    if (icon is Widget) {
      return IconTheme.merge(
        data: IconThemeData(size: widget.iconSize, color: iconColor),
        child: icon,
      );
    }

    throw ArgumentError.value(icon, 'icon', 'must be IconData or Widget');
  }
}
