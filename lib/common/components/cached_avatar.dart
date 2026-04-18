import 'package:bilimusic/common/components/cached_image.dart';
import 'package:flutter/material.dart';

class CommonCachedAvatar extends StatelessWidget {
  const CommonCachedAvatar({
    super.key,
    this.imageUrl,
    this.radius,
    this.size,
    this.backgroundColor,
    this.backgroundGradient,
    this.fallbackIcon = Icons.person_rounded,
    this.iconColor,
    this.iconSize,
  }) : assert(radius != null || size != null);

  final String? imageUrl;
  final double? radius;
  final double? size;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final IconData fallbackIcon;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = size ?? radius! * 2;

    return ClipOval(
      child: CommonCachedImage(
        imageUrl: imageUrl,
        width: resolvedSize,
        height: resolvedSize,
        fit: BoxFit.cover,
        backgroundColor: backgroundColor,
        backgroundGradient: backgroundGradient,
        fallbackIcon: fallbackIcon,
        iconColor: iconColor,
        iconSize: iconSize ?? resolvedSize * 0.5,
      ),
    );
  }
}
