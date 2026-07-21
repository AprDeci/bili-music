import 'package:bilimusic/feature/up/domain/collection_detail_state.dart';
import 'package:bilimusic/feature/up/domain/collection_item_page_result.dart';
import 'package:bilimusic/feature/up/domain/up_collection_item.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorited_season_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_detail_controller.g.dart';

@riverpod
class CollectionDetailController extends _$CollectionDetailController {
  @override
  Future<CollectionDetailState> build(int mid, int seasonId) {
    return _loadInitial(mid: mid, seasonId: seasonId);
  }

  Future<void> refresh() async {
    state = AsyncData(await _loadInitial(mid: mid, seasonId: seasonId));
  }

  Future<void> loadMoreItems() async {
    final CollectionDetailState? current = state.asData?.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreError: null),
    );
    try {
      final CollectionItemPageResult page = await ref
          .read(biliUpRepositoryProvider)
          .fetchCollectionItems(
            mid: mid,
            seasonId: seasonId,
            page: current.page + 1,
          );
      final CollectionDetailState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          collection: page.collection,
          items: <UpCollectionItem>[...latest.items, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error) {
      final CollectionDetailState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreError: error.toString()),
      );
    }
  }

  Future<CollectionDetailState> _loadInitial({
    required int mid,
    required int seasonId,
  }) async {
    try {
      final CollectionItemPageResult page = await ref
          .read(biliUpRepositoryProvider)
          .fetchCollectionItems(mid: mid, seasonId: seasonId, page: 1);
      await ref
          .read(favoritedSeasonControllerProvider.notifier)
          .syncIfFavorited(page.collection);
      return CollectionDetailState(
        collection: page.collection,
        items: page.items,
        page: page.page,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      return CollectionDetailState(error: error.toString());
    }
  }
}
