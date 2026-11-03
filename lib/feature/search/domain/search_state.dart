import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const SearchState._();

  const factory SearchState({
    @Default('') String query,
    String? submittedQuery,
    @Default(SearchType.video) SearchType type,
    @Default(SearchSort.comprehensive) SearchSort sort,
    @Default(<String>[]) List<String> recentKeywords,
    @Default(<String>[]) List<String> suggestions,
    @Default(PagedState<SearchResultItem>())
    PagedState<SearchResultItem> videoResults,
    @Default(PagedState<SearchUserItem>())
    PagedState<SearchUserItem> userResultsPage,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingSuggestions,
    String? errorMessage,
    String? suggestionsErrorMessage,
    String? loadMoreErrorMessage,
  }) = _SearchState;

  List<SearchResultItem> get results => videoResults.items;

  List<SearchUserItem> get userResults => userResultsPage.items;

  bool get isLoadingMore => type == SearchType.video
      ? videoResults.isLoadingMore
      : userResultsPage.isLoadingMore;

  int get currentPage =>
      type == SearchType.video ? videoResults.page : userResultsPage.page;

  bool get hasMore =>
      type == SearchType.video ? videoResults.hasMore : userResultsPage.hasMore;
}

extension SearchStateComputed on SearchState {
  int get activeResultCount {
    return resultCountFor(type);
  }

  int resultCountFor(SearchType type) {
    switch (type) {
      case SearchType.video:
        return videoResults.items.length;
      case SearchType.up:
        return userResultsPage.items.length;
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
