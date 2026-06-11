import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
      if (imageUrl.isEmpty || _preloadedUrls.contains(imageUrl)) continue;

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

  void _openGallery(int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CommentPictureGalleryPage(
            pictures: widget.pictures,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pictures.isEmpty) return const SizedBox.shrink();

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
            onTap: () => _openGallery(0),
          );
        }

        final int columnCount = widget.pictures.length > 2 ? 3 : 2;
        final double itemWidth =
            (maxWidth - (CommentPictureGallery._spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: CommentPictureGallery._spacing,
          runSpacing: CommentPictureGallery._spacing,
          children: widget.pictures.asMap().entries.map((entry) {
            final int index = entry.key;
            final CommentPicture picture = entry.value;
            return SizedBox(
              width: itemWidth,
              height: itemWidth,
              child: _PictureTile(
                picture: picture,
                borderColor: colorScheme.outlineVariant,
                onTap: () => _openGallery(index),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class CommentPictureGalleryPage extends StatefulWidget {
  final List<CommentPicture> pictures;
  final int initialIndex;

  const CommentPictureGalleryPage({
    super.key,
    required this.pictures,
    this.initialIndex = 0,
  });

  @override
  State<CommentPictureGalleryPage> createState() =>
      _CommentPictureGalleryPageState();
}

class _CommentPictureGalleryPageState extends State<CommentPictureGalleryPage> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("${currentIndex + 1} / ${widget.pictures.length}"),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: _pageController,
        itemCount: widget.pictures.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        builder: (BuildContext context, int index) {
          final String url = widget.pictures[index].imageUrl;
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              url,
              cacheManager: CacheUtil.imageCacheManager,
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            heroAttributes: PhotoViewHeroAttributes(tag: "comment_pic_$index"),
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 80),
            ),
          );
        },
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

class _SingleCommentPicture extends StatelessWidget {
  const _SingleCommentPicture({
    required this.picture,
    required this.maxWidth,
    required this.borderColor,
    required this.onTap,
  });

  final CommentPicture picture;
  final double maxWidth;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double aspectRatio = _resolveAspectRatio(picture);
    final double imageHeight = math.min(maxWidth / aspectRatio, 320);

    return SizedBox(
      width: maxWidth,
      height: imageHeight,
      child: _PictureTile(
        picture: picture,
        borderColor: borderColor,
        onTap: onTap,
      ),
    );
  }

  double _resolveAspectRatio(CommentPicture picture) {
    final int? width = picture.width;
    final int? height = picture.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 1.0;
    }

    return (width / height).clamp(
      CommentPictureGallery._singleImageMinAspectRatio,
      CommentPictureGallery._singleImageMaxAspectRatio,
    );
  }
}

class _PictureTile extends StatelessWidget {
  const _PictureTile({
    required this.picture,
    required this.borderColor,
    required this.onTap,
  });

  final CommentPicture picture;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "comment_pic_${picture.imageUrl.hashCode}",
        child: DecoratedBox(
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
        ),
      ),
    );
  }
}
