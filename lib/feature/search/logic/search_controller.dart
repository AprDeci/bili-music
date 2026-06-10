import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/data/search_history_store.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/domain/search_user_page_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

@riverpod
BiliSearchRepository biliSearchRepository(Ref ref) {
  return BiliSearchRepository(ref.read(biliClientProvider.notifier));
}

@riverpod
class SearchPageController extends _$SearchPageController {
  late final BiliSearchRepository _repository = ref.read(
    biliSearchRepositoryProvider,
  );
  late final SearchHistoryStore _historyStore = ref.read(
    searchHistoryStoreProvider,
  );
  int _suggestionRequestId = 0;
  String? _cacheKeyword;
  bool _videoLoaded = false;
  bool _userLoaded = false;
  int _videoPage = 0;
  int _userPage = 0;
  bool _videoHasMore = false;
  bool _userHasMore = false;

  @override
  SearchState build() {
    return SearchState(recentKeywords: _historyStore.load());
  }

  void updateQuery(String value) {
    final String nextQuery = value.trimLeft();
    state = state.copyWith(
      query: nextQuery,
      errorMessage: null,
      suggestionsErrorMessage: null,
    );
    loadSuggestions(nextQuery);
  }

  Future<void> submitSearch([String? value]) async {
    final String nextQuery = (value ?? state.query).trim();
    if (nextQuery.isEmpty) {
      state = state.copyWith(
        query: '',
        submittedQuery: null,
        suggestions: const <String>[],
        results: const <SearchResultItem>[],
        userResults: const <SearchUserItem>[],
        isLoading: false,
        isLoadingSuggestions: false,
        isLoadingMore: false,
        currentPage: 0,
        hasMore: false,
        errorMessage: null,
        suggestionsErrorMessage: null,
        loadMoreErrorMessage: null,
      );
      _resetResultCache();
      return;
    }

    final List<String> nextRecentKeywords = <String>[
      nextQuery,
      ...state.recentKeywords.where((String item) => item != nextQuery),
    ].take(20).toList();

    _resetResultCache(keyword: nextQuery);
    state = state.copyWith(
      query: nextQuery,
      submittedQuery: nextQuery,
      recentKeywords: nextRecentKeywords,
      suggestions: const <String>[],
      results: const <SearchResultItem>[],
      userResults: const <SearchUserItem>[],
      isLoading: true,
      isLoadingSuggestions: false,
      isLoadingMore: false,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
      suggestionsErrorMessage: null,
      loadMoreErrorMessage: null,
    );

    await _historyStore.save(nextRecentKeywords);

    try {
      final _SearchPageLoadResult page = await _loadPage(
        nextQuery,
        type: state.type,
        page: 1,
      );
      _recordLoadedPage(state.type, page);

      state = state.copyWith(
        results: page.videoItems,
        userResults: page.userItems,
        isLoading: false,
        currentPage: page.page,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      state = state.copyWith(
        results: const <SearchResultItem>[],
        userResults: const <SearchUserItem>[],
        isLoading: false,
        isLoadingSuggestions: false,
        isLoadingMore: false,
        currentPage: 0,
        hasMore: false,
        errorMessage: error.toString(),
        suggestionsErrorMessage: null,
        loadMoreErrorMessage: null,
      );
    }
  }

  Future<void> loadNextPage() async {
    final String submittedQuery = state.submittedQuery?.trim() ?? '';
    if (submittedQuery.isEmpty ||
        state.isLoading ||
        state.isLoadingMore ||
        !_hasMoreFor(state.type)) {
      return;
    }

    final SearchType activeType = state.type;
    final int nextPage = _pageFor(activeType) + 1;
    state = state.copyWith(isLoadingMore: true, loadMoreErrorMessage: null);

    try {
      final _SearchPageLoadResult page = await _loadPage(
        submittedQuery,
        type: activeType,
        page: nextPage,
      );
      final List<SearchResultItem> nextResults = activeType == SearchType.video
          ? <SearchResultItem>[...state.results, ...page.videoItems]
          : state.results;
      final List<SearchUserItem> nextUserResults = activeType == SearchType.up
          ? <SearchUserItem>[...state.userResults, ...page.userItems]
          : state.userResults;
      _recordLoadedPage(activeType, page);

      state = state.copyWith(
        results: nextResults,
        userResults: nextUserResults,
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

  Future<void> loadSuggestions(String value) async {
    final String term = value.trim();
    final int requestId = ++_suggestionRequestId;

    if (term.isEmpty) {
      state = state.copyWith(
        suggestions: const <String>[],
        isLoadingSuggestions: false,
        suggestionsErrorMessage: null,
      );
      return;
    }

    if (state.submittedQuery == term) {
      state = state.copyWith(
        suggestions: const <String>[],
        isLoadingSuggestions: false,
        suggestionsErrorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      isLoadingSuggestions: true,
      suggestionsErrorMessage: null,
    );

    try {
      final List<String> suggestions = await _repository.fetchSuggestions(term);
      if (requestId != _suggestionRequestId || state.query.trim() != term) {
        return;
      }

      state = state.copyWith(
        suggestions: suggestions,
        isLoadingSuggestions: false,
        suggestionsErrorMessage: null,
      );
    } on Object catch (error) {
      if (requestId != _suggestionRequestId || state.query.trim() != term) {
        return;
      }

      state = state.copyWith(
        suggestions: const <String>[],
        isLoadingSuggestions: false,
        suggestionsErrorMessage: error.toString(),
      );
    }
  }

  Future<void> changeSort(SearchSort sort) async {
    if (state.sort == sort) {
      return;
    }

    state = state.copyWith(sort: sort, loadMoreErrorMessage: null);
    if (state.type == SearchType.video &&
        ((state.submittedQuery?.isNotEmpty ?? false) ||
            state.query.trim().isNotEmpty)) {
      await submitSearch(state.submittedQuery ?? state.query);
    }
  }

  Future<_SearchPageLoadResult> _loadPage(
    String keyword, {
    required SearchType type,
    required int page,
  }) async {
    switch (type) {
      case SearchType.video:
        final SearchPageResult result = await _repository.searchVideos(
          keyword,
          page: page,
          sort: state.sort,
        );
        return _SearchPageLoadResult(
          videoItems: result.items,
          userItems: const <SearchUserItem>[],
          page: result.page,
          hasMore: result.hasMore,
        );
      case SearchType.up:
        final SearchUserPageResult result = await _repository.searchUsers(
          keyword,
          page: page,
        );
        return _SearchPageLoadResult(
          videoItems: const <SearchResultItem>[],
          userItems: result.items,
          page: result.page,
          hasMore: result.hasMore,
        );
    }
  }

  Future<void> changeType(SearchType type) async {
    if (state.type == type) {
      return;
    }

    final String submittedQuery = state.submittedQuery?.trim() ?? '';
    state = state.copyWith(
      type: type,
      currentPage: _pageFor(type),
      hasMore: _hasMoreFor(type),
      errorMessage: null,
      loadMoreErrorMessage: null,
    );
    if (submittedQuery.isEmpty || _isLoaded(type)) {
      return;
    }

    state = state.copyWith(isLoading: true, isLoadingMore: false);
    try {
      final _SearchPageLoadResult page = await _loadPage(
        submittedQuery,
        type: type,
        page: 1,
      );
      _recordLoadedPage(type, page);
      state = state.copyWith(
        results: type == SearchType.video ? page.videoItems : state.results,
        userResults: type == SearchType.up ? page.userItems : state.userResults,
        isLoading: false,
        currentPage: page.page,
        hasMore: page.hasMore,
        errorMessage: null,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        currentPage: 0,
        hasMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearQuery() {
    _suggestionRequestId++;
    state = state.copyWith(
      query: '',
      submittedQuery: null,
      suggestions: const <String>[],
      results: const <SearchResultItem>[],
      userResults: const <SearchUserItem>[],
      isLoading: false,
      isLoadingSuggestions: false,
      isLoadingMore: false,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
      suggestionsErrorMessage: null,
      loadMoreErrorMessage: null,
    );
    _resetResultCache();
  }

  void clearHistory() {
    state = state.copyWith(recentKeywords: <String>[]);
    _historyStore.clear();
  }

  void _resetResultCache({String? keyword}) {
    _cacheKeyword = keyword;
    _videoLoaded = false;
    _userLoaded = false;
    _videoPage = 0;
    _userPage = 0;
    _videoHasMore = false;
    _userHasMore = false;
  }

  bool _isLoaded(SearchType type) {
    if (_cacheKeyword != state.submittedQuery?.trim()) {
      return false;
    }
    switch (type) {
      case SearchType.video:
        return _videoLoaded;
      case SearchType.up:
        return _userLoaded;
    }
  }

  int _pageFor(SearchType type) {
    switch (type) {
      case SearchType.video:
        return _videoPage;
      case SearchType.up:
        return _userPage;
    }
  }

  bool _hasMoreFor(SearchType type) {
    switch (type) {
      case SearchType.video:
        return _videoHasMore;
      case SearchType.up:
        return _userHasMore;
    }
  }

  void _recordLoadedPage(SearchType type, _SearchPageLoadResult page) {
    switch (type) {
      case SearchType.video:
        _videoLoaded = true;
        _videoPage = page.page;
        _videoHasMore = page.hasMore;
      case SearchType.up:
        _userLoaded = true;
        _userPage = page.page;
        _userHasMore = page.hasMore;
    }
  }
}

class _SearchPageLoadResult {
  const _SearchPageLoadResult({
    required this.videoItems,
    required this.userItems,
    required this.page,
    required this.hasMore,
  });

  final List<SearchResultItem> videoItems;
  final List<SearchUserItem> userItems;
  final int page;
  final bool hasMore;
}
