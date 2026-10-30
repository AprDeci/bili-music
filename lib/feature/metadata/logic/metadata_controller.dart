import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_controller.g.dart';

@Riverpod(keepAlive: true)
class MetadataController extends _$MetadataController {
  final AppLogger _logger = AppLogger('MetadataController');

  late final MetadataLookupService _lookupService = ref.read(
    metadataLookupServiceProvider,
  );

  int _generation = 0;

  @override
  MetadataState build() {
    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      final String? previousTitle = previous == null
          ? null
          : _metadataTitleFromState(previous);
      final String? nextTitle = _metadataTitleFromState(next);
      if (previous?.currentItem?.stableId == next.currentItem?.stableId &&
          previous?.currentItem?.kind == next.currentItem?.kind &&
          previous?.currentItem?.collectionId ==
              next.currentItem?.collectionId &&
          previousTitle == nextTitle) {
        return;
      }
      unawaited(_loadCurrentItemMetadata());
    });
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    if (item != null && !item.isSpoken) {
      final int generation = _generation;
      unawaited(
        Future<void>.microtask(() async {
          if (ref.mounted && generation == _generation) {
            await _loadCurrentItemMetadata();
          }
        }),
      );
    }
    return MetadataState(
      stableId: item?.stableId,
      isLoading: item != null && !item.isSpoken,
    );
  }

  Future<void> retryCurrent() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _loadForItem(item, ignoreCache: true);
  }

  Future<void> adjustOffset(int deltaMs) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    final Metadata? metadata = state.metadata;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }
    if (metadata == null || metadata.stableId != stableId) {
      return;
    }

    final Metadata updatedMetadata = metadata.copyWith(
      lyricOffsetMs: metadata.lyricOffsetMs + deltaMs,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(metadata: updatedMetadata);
    await _saveCacheIfEligible(item: item, metadata: updatedMetadata);
  }

  Future<void> resetOffset() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    final Metadata? metadata = state.metadata;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }
    if (metadata == null || metadata.stableId != stableId) {
      return;
    }

    final Metadata updatedMetadata = metadata.copyWith(
      lyricOffsetMs: 0,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(metadata: updatedMetadata);
    await _saveCacheIfEligible(item: item, metadata: updatedMetadata);
  }

  Future<void> searchManual(String keyword, {MetingServer? server}) async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    final String? stableId = item?.stableId;
    if (item == null || item.isSpoken || state.stableId != stableId) {
      return;
    }

    final int requestGeneration = _generation;
    final String trimmedKeyword = keyword.trim();
    state = state.copyWith(
      searchKeyword: trimmedKeyword,
      manualSearchError: null,
      isSearching: true,
    );

    try {
      final MetingSearchResponse response = await _searchManually(
        keyword: trimmedKeyword,
        server: server,
      );
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      state = state.copyWith(
        searchKeyword: response.keyword,
        searchResults: response.results,
        manualSearchError: null,
        isSearching: false,
      );
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      state = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: error.message,
        isSearching: false,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      _logger.e('manual metadata search failed', error);
      state = state.copyWith(
        searchKeyword: trimmedKeyword,
        searchResults: const <MetingSearchItem>[],
        manualSearchError: '搜索失败：$error',
        isSearching: false,
      );
    }
  }

  Future<void> applyManualResult(MetingSearchItem item) async {
    final PlayableItem? currentItem = ref
        .read(playerControllerProvider)
        .currentItem;
    final String? stableId = currentItem?.stableId;
    if (currentItem == null ||
        currentItem.isSpoken ||
        state.stableId != stableId) {
      return;
    }

    final int requestGeneration = ++_generation;
    state = state.copyWith(
      manualSearchError: null,
      isSearching: true,
      isLoading: false,
    );

    try {
      final Metadata metadata = await _lookupService
          .buildMetadataFromSearchItem(
            item: currentItem,
            searchItem: item,
            isActive: () => _isActiveRequest(requestGeneration, currentItem),
          );
      if (!_isActiveRequest(requestGeneration, currentItem)) {
        return;
      }
      state = state.copyWith(
        metadata: metadata,
        errorMessage: null,
        manualSearchError: null,
        isSearching: false,
        hasSearched: true,
      );
      await _saveCacheIfEligible(item: currentItem, metadata: metadata);
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, currentItem)) {
        return;
      }
      state = state.copyWith(
        manualSearchError: error.message,
        isSearching: false,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, currentItem)) {
        return;
      }
      _logger.e('apply manual metadata result failed', error);
      state = state.copyWith(
        manualSearchError: '歌词加载失败：$error',
        isSearching: false,
      );
    }
  }

  Future<void> _loadCurrentItemMetadata() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _loadForItem(item);
  }

  Future<void> _loadForItem(
    PlayableItem? item, {
    bool ignoreCache = false,
  }) async {
    final int requestGeneration = ++_generation;
    if (item == null || item.isSpoken) {
      state = MetadataState(stableId: item?.stableId);
      return;
    }

    final String stableId = item.stableId;
    state = MetadataState(stableId: stableId, isLoading: true);

    if (!ignoreCache) {
      final Metadata? cached = await ref
          .read(metadataCacheRepositoryProvider)
          .getCachedMetadata(item: item);
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      if (cached != null) {
        state = MetadataState(
          stableId: stableId,
          metadata: cached,
          hasSearched: true,
        );
        return;
      }
    }

    try {
      final MetadataLookupResult lookupResult = await _resolve(
        item,
        requestGeneration,
      );
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }

      state = MetadataState(
        stableId: stableId,
        metadata: lookupResult.metadata,
        searchKeyword: lookupResult.searchKeyword,
        searchResults: lookupResult.searchResults,
        hasSearched: true,
      );
      await _saveCacheIfEligible(item: item, metadata: lookupResult.metadata);
    } on MetingException catch (error) {
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      state = MetadataState(
        stableId: stableId,
        errorMessage: error.message,
        searchKeyword: _lookupService.defaultSearchKeyword(item),
        hasSearched: true,
      );
    } on Object catch (error) {
      if (!_isActiveRequest(requestGeneration, item)) {
        return;
      }
      _logger.e('load metadata failed', error);
      state = MetadataState(
        stableId: stableId,
        errorMessage: '元信息查询失败：$error',
        searchKeyword: _lookupService.defaultSearchKeyword(item),
        hasSearched: true,
      );
    }
  }

  bool _isActiveRequest(int requestGeneration, PlayableItem item) {
    if (!ref.mounted || requestGeneration != _generation) {
      return false;
    }
    final PlayableItem? currentItem = ref
        .read(playerControllerProvider)
        .currentItem;
    return currentItem != null &&
        !currentItem.isSpoken &&
        currentItem.stableId == item.stableId &&
        currentItem.kind == item.kind &&
        currentItem.collectionId == item.collectionId &&
        state.stableId == item.stableId;
  }

  Future<void> _saveCacheIfEligible({
    required PlayableItem item,
    required Metadata metadata,
  }) async {
    if (!_shouldCacheMetadata(item)) {
      return;
    }

    await ref
        .read(metadataCacheRepositoryProvider)
        .putCachedMetadata(item: item, metadata: metadata);
  }

  bool _shouldCacheMetadata(PlayableItem item) {
    if (item.isSpoken) {
      return false;
    }
    return ref
        .read(favoritesControllerProvider)
        .collectionsForItem(item)
        .isNotEmpty;
  }

  Future<MetingSearchResponse> _searchManually({
    required String keyword,
    MetingServer? server,
  }) async {
    final MetingRepository metingRepository = ref.read(
      metingRepositoryProvider,
    );
    final String trimmedKeyword = keyword.trim();
    return MetingSearchResponse(
      keyword: trimmedKeyword,
      results: await metingRepository.search(
        keyword: trimmedKeyword,
        server: server ?? _resolveServer(trimmedKeyword),
      ),
    );
  }

  Future<MetadataLookupResult> _resolve(
    PlayableItem item,
    int requestGeneration,
  ) {
    return _lookupService.lookup(
      item: item,
      title: _preferredMetadataTitle(item),
      isActive: () => _isActiveRequest(requestGeneration, item),
    );
  }

  String _preferredMetadataTitle(PlayableItem item) {
    final PlayerState playerState = ref.read(playerControllerProvider);
    final bool hasMultipleParts =
        playerState.currentItem?.stableId == item.stableId &&
        playerState.availableParts.length > 1;

    return _metadataTitleForItem(item, hasMultipleParts: hasMultipleParts);
  }

  String? _metadataTitleFromState(PlayerState playerState) {
    final PlayableItem? item = playerState.currentItem;
    if (item == null) {
      return null;
    }

    return _metadataTitleForItem(
      item,
      hasMultipleParts: playerState.availableParts.length > 1,
    );
  }

  String _metadataTitleForItem(
    PlayableItem item, {
    required bool hasMultipleParts,
  }) {
    if (!hasMultipleParts) {
      return item.title.trim();
    }

    final String pageTitle = item.pageTitle?.trim() ?? '';
    if (pageTitle.isNotEmpty) {
      return pageTitle;
    }

    return item.title.trim();
  }

  MetingServer _resolveServer(String text) {
    return ref.read(metingSourcePreferenceLogicProvider).resolve(text);
  }
}
