import 'dart:async';

import 'package:adaptive_palette/adaptive_palette.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/player/logic/player_display_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_cover_color_provider.g.dart';

const int _paletteCacheExtent = 96;

@Riverpod(keepAlive: true)
class PlayerCoverColorController extends _$PlayerCoverColorController {
  String? _currentCoverUrl;
  int _generation = 0;

  @override
  Color? build() {
    ref.listen<String?>(
      playerDisplayProvider.select((display) => display.coverUrl),
      (_, coverUrl) {
        unawaited(
          Future<void>(() {
            if (ref.mounted) {
              _useCoverUrl(coverUrl);
            }
          }),
        );
      },
      fireImmediately: true,
    );

    return null;
  }

  String? get currentCoverUrl => _currentCoverUrl;

  Color? getCurrentColor() {
    return state;
  }

  void _useCoverUrl(String? coverUrl) {
    final String resolvedUrl = coverUrl?.trim() ?? '';
    if (_currentCoverUrl == resolvedUrl) {
      return;
    }

    _currentCoverUrl = resolvedUrl;
    final int generation = ++_generation;

    if (resolvedUrl.isEmpty) {
      state = null;
      return;
    }

    unawaited(_loadColor(resolvedUrl, generation));
  }

  Future<void> _loadColor(String coverUrl, int generation) async {
    try {
      final List<Color> colors = await FluidPaletteExtractor.extractColors(
        CachedNetworkImageProvider(
          coverUrl,
          cacheManager: CacheUtil.imageCacheManager,
          maxWidth: _paletteCacheExtent,
          maxHeight: _paletteCacheExtent,
        ),
        count: 1,
      );

      if (_currentCoverUrl != coverUrl || _generation != generation) {
        return;
      }

      state = colors.isEmpty ? null : colors.first;
    } on Object {
      if (_currentCoverUrl != coverUrl || _generation != generation) {
        return;
      }

      state = null;
    }
  }
}
