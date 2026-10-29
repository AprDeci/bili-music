import 'dart:async';

import 'package:adaptive_palette/adaptive_palette.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_cover_color_provider.g.dart';

const int _paletteCacheExtent = 96;

@riverpod
Future<Color?> playerArtworkColor(Ref ref, String coverUrl) async {
  if (coverUrl.trim().isEmpty) {
    return null;
  }
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
    return colors.isEmpty ? null : colors.first;
  } on Object {
    return null;
  }
}

@Riverpod(keepAlive: true)
class PlayerCoverColorController extends _$PlayerCoverColorController {
  String? _currentCoverUrl;
  ProviderSubscription<AsyncValue<Color?>>? _colorSubscription;

  @override
  Color? build() {
    ref.onDispose(() => _colorSubscription?.close());
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
    _colorSubscription?.close();

    if (resolvedUrl.isEmpty) {
      state = null;
      return;
    }

    _colorSubscription = ref.listen<AsyncValue<Color?>>(
      playerArtworkColorProvider(resolvedUrl),
      (_, color) {
        if (!color.isLoading) {
          state = color.asData?.value;
        }
      },
      fireImmediately: true,
    );
  }
}
