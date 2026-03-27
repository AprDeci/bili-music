import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_page_result.freezed.dart';

@freezed
abstract class SearchPageResult with _$SearchPageResult {
  const factory SearchPageResult({
    @Default(<SearchResultItem>[]) List<SearchResultItem> items,
    @Default(1) int page,
    int? totalPages,
    @Default(false) bool hasMore,
  }) = _SearchPageResult;
}
