import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'up_page_state.freezed.dart';

enum UpPageTab { videos, collections }

@freezed
abstract class UpPageState with _$UpPageState {
  const UpPageState._();

  const factory UpPageState({
    UpProfile? profile,
    @Default(PagedState<UpVideoItem>()) PagedState<UpVideoItem> videoFeed,
    @Default(PagedState<UpCollection>())
    PagedState<UpCollection> collectionFeed,
    @Default(UpPageTab.videos) UpPageTab selectedTab,
    @Default(false) bool isRefreshing,
    String? profileError,
    String? videoError,
    String? collectionError,
    String? videoLoadMoreError,
    String? collectionLoadMoreError,
  }) = _UpPageState;

  List<UpVideoItem> get videos => videoFeed.items;

  int get videoPage => videoFeed.page;

  bool get hasMoreVideos => videoFeed.hasMore;

  bool get isLoadingVideosMore => videoFeed.isLoadingMore;

  List<UpCollection> get collections => collectionFeed.items;

  int get collectionPage => collectionFeed.page;

  bool get hasMoreCollections => collectionFeed.hasMore;

  bool get isLoadingCollectionsMore => collectionFeed.isLoadingMore;
}
