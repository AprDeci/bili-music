import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_collection_item.dart';

part 'collection_item_page_result.freezed.dart';

@freezed
abstract class CollectionItemPageResult with _$CollectionItemPageResult {
  const factory CollectionItemPageResult({
    required UpCollection collection,
    required List<UpCollectionItem> items,
    required int page,
    required bool hasMore,
  }) = _CollectionItemPageResult;
}
