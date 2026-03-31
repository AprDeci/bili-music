import 'package:cached_network_image/cached_network_image.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:flutter/material.dart';

class CommonCachedImage extends StatelessWidget {
  const CommonCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.backgroundGradient,
    this.fallbackIcon = Icons.image_rounded,
    this.iconColor,
    this.iconSize,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final IconData fallbackIcon;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final String resolvedUrl = imageUrl?.trim() ?? '';
    final Widget loadingState = placeholder ?? _buildDefaultFallback();
    final Widget failureState =
        errorWidget ?? placeholder ?? _buildDefaultFallback();

    Widget child;
    if (resolvedUrl.isEmpty) {
      child = failureState;
    } else {
      child = CachedNetworkImage(
        cacheManager: CacheUtil.imageCacheManager,
        imageUrl: resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (BuildContext context, String url) {
          return loadingState;
        },
        errorWidget: (BuildContext context, String url, Object error) {
          return failureState;
        },
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    return child;
  }

  Widget _buildDefaultFallback() {
    final Color resolvedIconColor = iconColor ?? const Color(0xFF7A8CA5);
    final double resolvedIconSize = iconSize ?? 24;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundGradient == null
            ? backgroundColor ?? const Color(0xFFF3F6FB)
            : null,
        gradient: backgroundGradient,
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: resolvedIconColor,
          size: resolvedIconSize,
        ),
      ),
    );
  }
}
