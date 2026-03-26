import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.submittedQuery,
    this.recentKeywords = const <String>[],
    this.results = const <SearchResultItem>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final String? submittedQuery;
  final List<String> recentKeywords;
  final List<SearchResultItem> results;
  final bool isLoading;
  final String? errorMessage;

  SearchState copyWith({
    String? query,
    String? submittedQuery,
    bool clearSubmittedQuery = false,
    List<String>? recentKeywords,
    List<SearchResultItem>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      submittedQuery: clearSubmittedQuery
          ? null
          : submittedQuery ?? this.submittedQuery,
      recentKeywords: recentKeywords ?? this.recentKeywords,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
