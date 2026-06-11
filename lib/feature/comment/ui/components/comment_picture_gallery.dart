import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter/material.dart';

class CommentPictureGallery extends StatefulWidget {
  const CommentPictureGallery({super.key, required this.pictures});

  static const double _spacing = 8;
  static const double _singleImageMaxWidth = 280;
  static const double _singleImageMinAspectRatio = 0.75;
  static const double _singleImageMaxAspectRatio = 1.8;
  final List<CommentPicture> pictures;

  @override
  State<CommentPictureGallery> createState() => _CommentPictureGalleryState();
}

class _CommentPictureGalleryState extends State<CommentPictureGallery> {
  static final Set<String> _preloadedUrls = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadPictures();
  }

  @override
  void didUpdateWidget(covariant CommentPictureGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pictures != widget.pictures) {
      _preloadPictures();
    }
  }

  void _preloadPictures() {
    for (final CommentPicture picture in widget.pictures.take(3)) {
      final String imageUrl = picture.imageUrl.trim();
      if (imageUrl.isEmpty || _preloadedUrls.contains(imageUrl)) {
        continue;
      }

      _preloadedUrls.add(imageUrl);
      precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          cacheManager: CacheUtil.imageCacheManager,
        ),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pictures.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : CommentPictureGallery._singleImageMaxWidth;

        if (widget.pictures.length == 1) {
          return _SingleCommentPicture(
            picture: widget.pictures.first,
            maxWidth: math.min(
              maxWidth,
              CommentPictureGallery._singleImageMaxWidth,
            ),
            borderColor: colorScheme.outlineVariant,
          );
        }

        final int columnCount = widget.pictures.length > 2 ? 3 : 2;
        final double itemWidth =
            (maxWidth - (CommentPictureGallery._spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: CommentPictureGallery._spacing,
          runSpacing: CommentPictureGallery._spacing,
          children: widget.pictures.map((CommentPicture picture) {
            return SizedBox(
              width: itemWidth,
              height: itemWidth,
              child: _PictureTile(
                picture: picture,
                borderColor: colorScheme.outlineVariant,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SingleCommentPicture extends StatelessWidget {
  const _SingleCommentPicture({
    required this.picture,
    required this.maxWidth,
    required this.borderColor,
  });

  final CommentPicture picture;
  final double maxWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final double aspectRatio = _resolveAspectRatio(picture);
    final double imageWidth = maxWidth;
    final double imageHeight = math.min(imageWidth / aspectRatio, 320);

    return SizedBox(
      width: imageWidth,
      height: imageHeight,
      child: _PictureTile(picture: picture, borderColor: borderColor),
    );
  }

  double _resolveAspectRatio(CommentPicture picture) {
    final int? width = picture.width;
    final int? height = picture.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 1;
    }

    return (width / height).clamp(
      CommentPictureGallery._singleImageMinAspectRatio,
      CommentPictureGallery._singleImageMaxAspectRatio,
    );
  }
}

class _PictureTile extends StatelessWidget {
  const _PictureTile({required this.picture, required this.borderColor});

  final CommentPicture picture;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.7)),
      ),
      child: CommonCachedImage(
        imageUrl: picture.imageUrl,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        memCacheWidth: 360,
        memCacheHeight: 360,
        maxDiskCacheWidth: 720,
        maxDiskCacheHeight: 720,
      ),
    );
  }
}
