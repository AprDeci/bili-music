import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/data/search_history_store.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

@riverpod
BiliSearchRepository biliSearchRepository(Ref ref) {
  return BiliSearchRepository(ref.read(biliApiClientProvider));
}

@riverpod
class SearchPageController extends _$SearchPageController {
  late final BiliSearchRepository _repository = ref.read(
    biliSearchRepositoryProvider,
  );
  late final SearchHistoryStore _historyStore = ref.read(
    searchHistoryStoreProvider,
  );

  @override
  SearchState build() {
    return SearchState(recentKeywords: _historyStore.load());
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value, errorMessage: null);
  }

  Future<void> submitSearch([String? value]) async {
    final String nextQuery = (value ?? state.query).trim();
    if (nextQuery.isEmpty) {
      state = state.copyWith(
        query: '',
        submittedQuery: null,
        results: const <SearchResultItem>[],
        isLoading: false,
        errorMessage: null,
      );
      return;
    }

    final List<String> nextRecentKeywords = <String>[
      nextQuery,
      ...state.recentKeywords.where((String item) => item != nextQuery),
    ].take(20).toList();

    state = state.copyWith(
      query: nextQuery,
      submittedQuery: nextQuery,
      recentKeywords: nextRecentKeywords,
      isLoading: true,
      errorMessage: null,
    );

    await _historyStore.save(nextRecentKeywords);

    try {
      final List<SearchResultItem> results = await _repository.searchVideos(
        nextQuery,
      );
      state = state.copyWith(results: results, isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(
        results: const <SearchResultItem>[],
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectKeyword(String value) async {
    state = state.copyWith(query: value);
    await submitSearch(value);
  }

  void clearQuery() {
    state = state.copyWith(
      query: '',
      submittedQuery: null,
      results: const <SearchResultItem>[],
      isLoading: false,
      errorMessage: null,
    );
  }

  void clearHistory() {
    state = state.copyWith(recentKeywords: <String>[]);
    _historyStore.clear();
  }
}
