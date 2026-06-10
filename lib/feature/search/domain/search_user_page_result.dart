import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_user_page_result.freezed.dart';

@freezed
abstract class SearchUserPageResult with _$SearchUserPageResult {
  const factory SearchUserPageResult({
    @Default(<SearchUserItem>[]) List<SearchUserItem> items,
    @Default(1) int page,
    int? totalPages,
    @Default(false) bool hasMore,
  }) = _SearchUserPageResult;
}
