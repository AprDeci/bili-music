import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/data/search_history_store.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
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
        isLoadingMore: false,
        currentPage: 0,
        hasMore: false,
        errorMessage: null,
        loadMoreErrorMessage: null,
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
      results: const <SearchResultItem>[],
      isLoading: true,
      isLoadingMore: false,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
      loadMoreErrorMessage: null,
    );

    await _historyStore.save(nextRecentKeywords);

    try {
      final SearchPageResult page = await _repository.searchVideos(
        nextQuery,
        page: 1,
      );

      state = state.copyWith(
        results: page.items,
        isLoading: false,
        currentPage: page.page,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      state = state.copyWith(
        results: const <SearchResultItem>[],
        isLoading: false,
        isLoadingMore: false,
        currentPage: 0,
        hasMore: false,
        errorMessage: error.toString(),
        loadMoreErrorMessage: null,
      );
    }
  }

  Future<void> loadNextPage() async {
    final String submittedQuery = state.submittedQuery?.trim() ?? '';
    if (submittedQuery.isEmpty ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final int nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, loadMoreErrorMessage: null);

    try {
      final SearchPageResult page = await _repository.searchVideos(
        submittedQuery,
        page: nextPage,
      );
      final List<SearchResultItem> nextResults = <SearchResultItem>[
        ...state.results,
        ...page.items,
      ];

      state = state.copyWith(
        results: nextResults,
        isLoadingMore: false,
        currentPage: page.page,
        hasMore: page.hasMore,
        loadMoreErrorMessage: null,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreErrorMessage: error.toString(),
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
      isLoadingMore: false,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
      loadMoreErrorMessage: null,
    );
  }

  void clearHistory() {
    state = state.copyWith(recentKeywords: <String>[]);
    _historyStore.clear();
  }
}
