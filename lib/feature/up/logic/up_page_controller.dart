import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/up/data/bili_up_repository.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_collection_page_result.dart';
import 'package:bilimusic/feature/up/domain/up_page_state.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';
import 'package:bilimusic/feature/up/domain/up_video_page_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'up_page_controller.g.dart';

@riverpod
BiliUpRepository biliUpRepository(Ref ref) {
  return BiliUpRepository(ref.read(biliClientProvider.notifier));
}

@riverpod
class UpPageController extends _$UpPageController {
  late final BiliUpRepository _repository = ref.read(biliUpRepositoryProvider);

  @override
  Future<UpPageState> build(int mid) {
    return _loadInitial(mid);
  }

  Future<void> refresh() async {
    final UpPageState previous = state.asData?.value ?? const UpPageState();
    state = AsyncData(previous.copyWith(isRefreshing: true));
    state = AsyncData(await _loadInitial(mid));
  }

  void selectTab(UpPageTab tab) {
    final UpPageState? current = state.asData?.value;
    if (current == null || current.selectedTab == tab) {
      return;
    }
    state = AsyncData(current.copyWith(selectedTab: tab));
  }

  Future<void> loadMoreVideos() async {
    final UpPageState? current = state.asData?.value;
    if (current == null ||
        current.isLoadingVideosMore ||
        !current.hasMoreVideos) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        videoFeed: current.videoFeed.startingNextPage(),
        videoLoadMoreError: null,
      ),
    );
    try {
      final UpVideoPageResult page = await _repository.fetchVideos(
        mid: mid,
        page: current.videoPage + 1,
        ownerName: current.profile?.name ?? '',
      );
      final UpPageState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          videoFeed: latest.videoFeed.withNextPage(
            page.items,
            page: page.page,
            hasMore: page.hasMore,
          ),
          videoLoadMoreError: null,
        ),
      );
    } on Object catch (error) {
      final UpPageState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          videoFeed: latest.videoFeed.failed(error),
          videoLoadMoreError: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreCollections() async {
    final UpPageState? current = state.asData?.value;
    if (current == null ||
        current.isLoadingCollectionsMore ||
        !current.hasMoreCollections) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        collectionFeed: current.collectionFeed.startingNextPage(),
        collectionLoadMoreError: null,
      ),
    );
    try {
      final UpCollectionPageResult page = await _repository.fetchCollections(
        mid: mid,
        page: current.collectionPage + 1,
      );
      final UpPageState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          collectionFeed: latest.collectionFeed.withNextPage(
            page.items,
            page: page.page,
            hasMore: page.hasMore,
          ),
          collectionLoadMoreError: null,
        ),
      );
    } on Object catch (error) {
      final UpPageState latest = state.asData?.value ?? current;
      state = AsyncData(
        latest.copyWith(
          collectionFeed: latest.collectionFeed.failed(error),
          collectionLoadMoreError: error.toString(),
        ),
      );
    }
  }

  Future<UpPageState> _loadInitial(int mid) async {
    UpProfile? profile;
    UpVideoPageResult? videos;
    UpCollectionPageResult? collections;
    String? profileError;
    String? videoError;
    String? collectionError;

    try {
      profile = await _repository.fetchProfile(mid: mid);
    } on Object catch (error) {
      profileError = error.toString();
    }

    await Future.wait(<Future<void>>[
      (() async {
        try {
          videos = await _repository.fetchVideos(
            mid: mid,
            page: 1,
            ownerName: profile?.name ?? '',
          );
        } on Object catch (error) {
          videoError = error.toString();
        }
      })(),
      (() async {
        try {
          collections = await _repository.fetchCollections(mid: mid, page: 1);
        } on Object catch (error) {
          collectionError = error.toString();
        }
      })(),
    ]);

    return UpPageState(
      profile: profile,
      videoFeed: _firstPageFeed<UpVideoItem>(
        videos?.items,
        page: videos?.page,
        hasMore: videos?.hasMore,
      ),
      collectionFeed: _firstPageFeed<UpCollection>(
        collections?.items,
        page: collections?.page,
        hasMore: collections?.hasMore,
      ),
      profileError: profileError,
      videoError: videoError,
      collectionError: collectionError,
    );
  }

  PagedState<T> _firstPageFeed<T>(
    List<T>? items, {
    required int? page,
    required bool? hasMore,
  }) {
    if (items == null) {
      return PagedState<T>();
    }
    return PagedState<T>().withFirstPage(
      items,
      page: page ?? 0,
      hasMore: hasMore ?? false,
    );
  }
}
