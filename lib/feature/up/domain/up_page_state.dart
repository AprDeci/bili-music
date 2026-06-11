import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';

part 'up_page_state.freezed.dart';

enum UpPageTab { videos, collections }

@freezed
abstract class UpPageState with _$UpPageState {
  const factory UpPageState({
    UpProfile? profile,
    @Default(<UpVideoItem>[]) List<UpVideoItem> videos,
    @Default(0) int videoPage,
    @Default(false) bool hasMoreVideos,
    @Default(false) bool isLoadingVideosMore,
    @Default(<UpCollection>[]) List<UpCollection> collections,
    @Default(0) int collectionPage,
    @Default(false) bool hasMoreCollections,
    @Default(false) bool isLoadingCollectionsMore,
    @Default(UpPageTab.videos) UpPageTab selectedTab,
    @Default(false) bool isRefreshing,
    String? profileError,
    String? videoError,
    String? collectionError,
    String? videoLoadMoreError,
    String? collectionLoadMoreError,
  }) = _UpPageState;
}
