import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:flutter/material.dart';

enum BadgeType { person, institution }

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.avatarUrl,
    this.officialType,
    this.useCache = false,
  });

  final String avatarUrl;
  final int? officialType;
  final bool useCache;
  final double radius = 26;
  final double tipSize = 16;

  BadgeType? get _badgeType {
    return switch (officialType) {
      0 => BadgeType.person,
      1 => BadgeType.institution,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double avatarSize = radius * 2;
    final BadgeType? badgeType = _badgeType;

    return Stack(
      children: <Widget>[
        ClipOval(
          child: SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: _buildAvatarImage(colorScheme, avatarSize),
          ),
        ),
        if (badgeType != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: _BuildBadge(type: badgeType, size: tipSize),
          ),
      ],
    );
  }

  Widget _buildAvatarImage(ColorScheme colorScheme, double avatarSize) {
    final Widget fallback = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person_rounded, color: colorScheme.onSurfaceVariant),
    );

    if (useCache) {
      return CommonCachedAvatar(
        size: avatarSize,
        imageUrl: avatarUrl,
        fallbackIcon: Icons.person_rounded,
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconColor: colorScheme.onSurfaceVariant,
      );
    }

    if (avatarUrl.isEmpty) {
      return fallback;
    }

    return Image.network(
      avatarUrl,
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return fallback;
          },
    );
  }
}

class _BuildBadge extends StatelessWidget {
  const _BuildBadge({required this.type, required this.size});

  final BadgeType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (type) {
      BadgeType.person => const Color(0xFFFFCC00),
      BadgeType.institution => Colors.lightBlueAccent,
    };

    return Icon(Icons.offline_bolt, size: size, color: color);
  }
}
