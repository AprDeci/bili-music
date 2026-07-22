import 'dart:async';

import 'package:adaptive_palette/adaptive_palette.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_cover_logic.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_display_metadata.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_cover_color_provider.g.dart';

const int _paletteCacheExtent = 96;

@Riverpod(keepAlive: true)
class PlayerCoverColorController extends _$PlayerCoverColorController {
  String? _currentCoverUrl;
  int _generation = 0;

  @override
  Color? build() {
    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      if (previous?.currentItem?.stableId == next.currentItem?.stableId) {
        return;
      }

      _scheduleUseCurrentCoverUrl();
    }, fireImmediately: true);

    ref.listen<MetadataState>(metadataControllerProvider, (
      MetadataState? previous,
      MetadataState next,
    ) {
      if (previous?.metadata?.albumArtUrl == next.metadata?.albumArtUrl &&
          previous?.stableId == next.stableId) {
        return;
      }

      _scheduleUseCurrentCoverUrl();
    }, fireImmediately: true);

    ref.listen<bool>(playerCoverSettingsLogicProvider, (_, _) {
      _scheduleUseCurrentCoverUrl();
    });
    ref.listen<bool?>(playerCoverLogicProvider, (_, _) {
      _scheduleUseCurrentCoverUrl();
    });

    return null;
  }

  String? get currentCoverUrl => _currentCoverUrl;

  Color? getCurrentColor() {
    return state;
  }

  void _scheduleUseCurrentCoverUrl() {
    unawaited(
      Future<void>(() {
        _useCoverUrl(_resolveCurrentCoverUrl());
      }),
    );
  }

  String? _resolveCurrentCoverUrl() {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    if (item == null) {
      return null;
    }

    final MetadataState metadataState = ref.read(metadataControllerProvider);
    final bool defaultUseMetadataCover = ref.read(
      playerCoverSettingsLogicProvider,
    );
    final bool useMetadataCover =
        ref.read(playerCoverLogicProvider) ?? defaultUseMetadataCover;
    return resolveDisplayCoverUrl(
      item: item,
      metadata: metadataState.stableId == item.stableId
          ? metadataState.metadata
          : null,
      useMetadataCover: useMetadataCover,
    );
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
