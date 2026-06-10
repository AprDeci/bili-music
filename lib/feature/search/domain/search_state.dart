import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    String? submittedQuery,
    @Default(SearchType.video) SearchType type,
    @Default(SearchSort.comprehensive) SearchSort sort,
    @Default(<String>[]) List<String> recentKeywords,
    @Default(<String>[]) List<String> suggestions,
    @Default(<SearchResultItem>[]) List<SearchResultItem> results,
    @Default(<SearchUserItem>[]) List<SearchUserItem> userResults,
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

extension SearchStateComputed on SearchState {
  int get activeResultCount {
    return resultCountFor(type);
  }

  int resultCountFor(SearchType type) {
    switch (type) {
      case SearchType.video:
        return results.length;
      case SearchType.up:
        return userResults.length;
    }
  }

  bool isLoadingFor(SearchType type) {
    return this.type == type && isLoading;
  }

  bool isLoadingMoreFor(SearchType type) {
    return this.type == type && isLoadingMore;
  }

  bool hasMoreFor(SearchType type) {
    return this.type == type && hasMore;
  }

  String? errorMessageFor(SearchType type) {
    return this.type == type ? errorMessage : null;
  }

  String? loadMoreErrorMessageFor(SearchType type) {
    return this.type == type ? loadMoreErrorMessage : null;
  }
}
