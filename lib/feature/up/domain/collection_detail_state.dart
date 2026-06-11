import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_collection_item.dart';

part 'collection_detail_state.freezed.dart';

@freezed
abstract class CollectionDetailState with _$CollectionDetailState {
  const factory CollectionDetailState({
    UpCollection? collection,
    @Default(<UpCollectionItem>[]) List<UpCollectionItem> items,
    @Default(0) int page,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    String? error,
    String? loadMoreError,
  }) = _CollectionDetailState;
}
