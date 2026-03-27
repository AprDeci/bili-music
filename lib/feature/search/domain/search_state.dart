import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    String? submittedQuery,
    @Default(<String>[]) List<String> recentKeywords,
    @Default(<SearchResultItem>[]) List<SearchResultItem> results,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(0) int currentPage,
    @Default(false) bool hasMore,
    String? errorMessage,
    String? loadMoreErrorMessage,
  }) = _SearchState;
}
