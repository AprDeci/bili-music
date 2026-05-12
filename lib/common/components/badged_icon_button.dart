import 'package:flutter/material.dart';

class BadgedIconButton extends StatefulWidget {
  const BadgedIconButton({
    super.key,
    required this.noBadgeIcon,
    required this.badgeIcon,
    required this.onPressed,
    this.badge,
    this.size = 40,
    this.iconSize = 24,
    this.tapRadius = 24,
    this.badgeOffset = const Offset(-4, 4),
    this.enabledColor,
    this.disabledColor,
    this.hoverColor,
    this.activeColor,
    this.isActive = false,
    this.tooltip,
    this.cursor,
  });

  final Widget noBadgeIcon;
  final Widget badgeIcon;
  final VoidCallback? onPressed;
  final Object? badge;
  final double size;
  final double iconSize;
  final double tapRadius;
  final Offset badgeOffset;
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? hoverColor;
  final Color? activeColor;
  final bool isActive;
  final String? tooltip;
  final MouseCursor? cursor;

  @override
  State<BadgedIconButton> createState() => _BadgedIconButtonState();
}

class _BadgedIconButtonState extends State<BadgedIconButton> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null;
  bool get _hasBadge => widget.badge != null;

  @override
  Widget build(BuildContext context) {
    final Object? badge = widget.badge;
    final Color iconColor = _resolveIconColor(context);
    final Offset badgeOffset = _resolveBadgeOffset(badge);

    final Widget button = MouseRegion(
      cursor: _isEnabled
          ? widget.cursor ?? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: _isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          GestureDetector(
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: widget.iconSize,
                      color: iconColor,
                    ),
                    child: _hasBadge ? widget.badgeIcon : widget.noBadgeIcon,
                  ),
                ),
              ),
            ),
          ),
          if (_isEnabled && badge != null)
            Positioned(
              top: badgeOffset.dy,
              right: badgeOffset.dx,
              child: IgnorePointer(
                child: BadgedIconButtonBadge(content: badge, color: iconColor),
              ),
            ),
        ],
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

  Color _resolveIconColor(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (!_isEnabled) {
      return widget.disabledColor ??
          colorScheme.onSurface.withValues(alpha: 0.38);
    }
    if (widget.isActive) {
      return widget.activeColor ?? colorScheme.primary;
    }
    if (_isHovered) {
      return widget.hoverColor ?? colorScheme.primary;
    }
    return widget.enabledColor ?? colorScheme.onSurface;
  }

  Offset _resolveBadgeOffset(Object? badge) {
    if (badge is! String) {
      return widget.badgeOffset;
    }

    final int digitCount = badge.length;
    final double dx = 0 - (digitCount - 1) * 2;
    return Offset(dx, 4);
  }
}

class BadgedIconButtonBadge extends StatelessWidget {
  const BadgedIconButtonBadge({
    super.key,
    required this.content,
    required this.color,
  }) : assert(content is String || content is Widget);

  final Object content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      child: _buildChild(theme, color),
    );
  }

  Widget _buildChild(ThemeData theme, Color color) {
    final Object content = this.content;
    if (content is Widget) {
      return IconTheme.merge(
        data: IconThemeData(color: color),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: content,
        ),
      );
    }
    return Text(
      content as String,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 8,
        height: 1,
      ),
    );
  }
}
