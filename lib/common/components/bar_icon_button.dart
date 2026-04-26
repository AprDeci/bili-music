import 'package:bilimusic/common/components/icon_and_widget.dart';
import 'package:flutter/material.dart';

class BarIconButton extends StatefulWidget {
  const BarIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.iconSize = 20,
    this.isActive = false,
    this.activeColor,
  });

  final VoidCallback? onPressed;
  final Object icon;
  final String? tooltip;
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

    final Widget button = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: IconAndWidget(
              icon: widget.icon,
              size: widget.iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    final String? tooltip = widget.tooltip;
    if (tooltip == null) {
      return button;
    }

    return Tooltip(
      waitDuration: const Duration(milliseconds: 600),
      message: tooltip,
      child: button,
    );
  }
}
