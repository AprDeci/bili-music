import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';

part 'up_collection_page_result.freezed.dart';

@freezed
abstract class UpCollectionPageResult with _$UpCollectionPageResult {
  const factory UpCollectionPageResult({
    required List<UpCollection> items,
    required int page,
    required bool hasMore,
  }) = _UpCollectionPageResult;
}
