import 'dart:math' as math;

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter/material.dart';

class CommentPictureGallery extends StatelessWidget {
  const CommentPictureGallery({super.key, required this.pictures});

  static const double _spacing = 8;
  static const double _singleImageMaxWidth = 280;
  static const double _singleImageMinAspectRatio = 0.75;
  static const double _singleImageMaxAspectRatio = 1.8;
  final List<CommentPicture> pictures;

  @override
  Widget build(BuildContext context) {
    if (pictures.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _singleImageMaxWidth;

        if (pictures.length == 1) {
          return _SingleCommentPicture(
            picture: pictures.first,
            maxWidth: math.min(maxWidth, _singleImageMaxWidth),
            borderColor: colorScheme.outlineVariant,
          );
        }

        final int columnCount = pictures.length > 2 ? 3 : 2;
        final double itemWidth =
            (maxWidth - (_spacing * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: pictures.map((CommentPicture picture) {
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
      ),
    );
  }
}
