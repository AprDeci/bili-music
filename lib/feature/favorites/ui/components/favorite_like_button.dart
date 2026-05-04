import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:flutter/material.dart';

const Color favoriteLikeColor = Color(0xFFF33939);

class FavoriteLikeIconButton extends StatelessWidget {
  const FavoriteLikeIconButton({
    super.key,
    required this.isLiked,
    required this.onPressed,
    this.isEnabled = true,
    this.iconSize = 28,
    this.tooltip = '我喜欢',
  });

  final bool isLiked;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final VoidCallback? effectiveOnPressed = isEnabled ? onPressed : null;
    final Widget button = IconButton(
      onPressed: effectiveOnPressed,
      icon: Icon(
        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      ),
      color: isLiked
          ? favoriteLikeColor
          : colorScheme.onSurface.withValues(alpha: 0.55),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.28),
      iconSize: iconSize,
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

class FavoriteLikeBarButton extends StatelessWidget {
  const FavoriteLikeBarButton({
    super.key,
    required this.isLiked,
    required this.onPressed,
    this.tooltip = '我喜欢',
  });

  final bool isLiked;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return BarIconButton(
      icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      tooltip: tooltip,
      isActive: isLiked,
      activeColor: favoriteLikeColor,
      onPressed: onPressed,
    );
  }
}
