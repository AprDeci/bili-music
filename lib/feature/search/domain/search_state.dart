import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    String? submittedQuery,
    @Default(SearchSort.comprehensive) SearchSort sort,
    @Default(<String>[]) List<String> recentKeywords,
    @Default(<String>[]) List<String> suggestions,
    @Default(<SearchResultItem>[]) List<SearchResultItem> results,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingSuggestions,
    @Default(false) bool isLoadingMore,
    @Default(0) int currentPage,
    @Default(false) bool hasMore,
    String? errorMessage,
    String? suggestionsErrorMessage,
    String? loadMoreErrorMessage,
  }) = _SearchState;
}
