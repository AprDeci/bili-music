import 'package:bilimusic/common/util/color_util.dart';
import 'package:flutter/material.dart';

class PlayerTrackHeader extends StatelessWidget {
  const PlayerTrackHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isFavoriteEnabled,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final String title;
  final String subtitle;
  final bool isFavoriteEnabled;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: isFavoriteEnabled ? onFavoriteToggle : null,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          ),
          color: isFavorite
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.55),
          iconSize: 28,
        ),
      ],
    );
  }
}

class SwipeHint extends StatelessWidget {
  const SwipeHint({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(
          Icons.swipe_left_alt_rounded,
          size: 18,
          color: colorScheme.primary.withValues(alpha: 0.72),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class PlayerBackdropOrb extends StatelessWidget {
  const PlayerBackdropOrb({super.key, this.size = 260, this.opacity = 0.45});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              primary.withValues(alpha: opacity * 0.45),
              primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerBadge extends StatelessWidget {
  const PlayerBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorUtil.getShade(
          theme.colorScheme.primary,
          500,
        ).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
