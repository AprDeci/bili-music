import 'dart:async';

import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/data/search_history_store.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/domain/search_user_page_result.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads suggestions for query updates', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(
          _FakeBiliSearchRepository(
            suggestionsByTerm: <String, List<String>>{
              '洛天依': <String>['洛天依', '洛天依歌曲'],
            },
          ),
        ),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    controller.updateQuery('洛天依');
    await Future<void>.delayed(Duration.zero);

    final state = container.read(searchPageControllerProvider);
    expect(state.query, '洛天依');
    expect(state.suggestions, <String>['洛天依', '洛天依歌曲']);
    expect(state.isLoadingSuggestions, isFalse);
  });

  test('loads suggestions for an already submitted query', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(
          _FakeBiliSearchRepository(
            suggestionsByTerm: <String, List<String>>{
              '洛天依': <String>['洛天依', '洛天依歌曲'],
            },
          ),
        ),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    await controller.submitSearch('洛天依');
    await controller.loadSuggestions('洛天依');

    final SearchState state = container.read(searchPageControllerProvider);
    expect(state.suggestions, <String>['洛天依', '洛天依歌曲']);
    expect(state.isLoadingSuggestions, isFalse);
  });

  test('changeSort reloads submitted query with new sort', () async {
    final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository(
      searchResultsByKeyword: <String, SearchPageResult>{
        'vocaloid': const SearchPageResult(),
      },
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(repository),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    await controller.submitSearch('vocaloid');
    await controller.changeSort(SearchSort.newest);

    expect(repository.searchRequests.length, 2);
    expect(repository.searchRequests.first.sort, SearchSort.comprehensive);
    expect(repository.searchRequests.last.sort, SearchSort.newest);
    expect(
      container.read(searchPageControllerProvider).sort,
      SearchSort.newest,
    );
  });

  test('changeType reloads submitted query with user search', () async {
    final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository(
      userResultsByKeyword: <String, SearchUserPageResult>{
        '洛天依': SearchUserPageResult(
          items: <SearchUserItem>[
            SearchUserItem(
              mid: 36081646,
              name: '洛天依',
              avatarUrl: '',
              sign: '虚拟歌手',
              fansText: '198.3万',
              videoCountText: '45',
              level: 6,
            ),
          ],
        ),
      },
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(repository),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    await controller.submitSearch('洛天依');
    await controller.changeType(SearchType.up);

    final SearchState state = container.read(searchPageControllerProvider);
    expect(repository.searchRequests.length, 1);
    expect(repository.userSearchRequests, <String>['洛天依']);
    expect(state.type, SearchType.up);
    expect(state.results, isEmpty);
    expect(state.userResults.single.mid, 36081646);
  });

  test('changeType keeps cached tab results without reloading', () async {
    final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository(
      searchResultsByKeyword: <String, SearchPageResult>{
        '洛天依': const SearchPageResult(page: 1, hasMore: false),
      },
      userResultsByKeyword: <String, SearchUserPageResult>{
        '洛天依': const SearchUserPageResult(page: 1, hasMore: false),
      },
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(repository),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    await controller.submitSearch('洛天依');
    await controller.changeType(SearchType.up);
    await controller.changeType(SearchType.video);
    await controller.changeType(SearchType.up);

    expect(repository.searchRequests.length, 1);
    expect(repository.userSearchRequests, <String>['洛天依']);
  });

  for (final SearchType type in SearchType.values) {
    test(
      '${type.name} pagination failure preserves results and retries',
      () async {
        final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository(
          searchResultsByKeyword: <String, SearchPageResult>{
            '洛天依': const SearchPageResult(
              items: <SearchResultItem>[
                SearchResultItem(
                  aid: 1,
                  bvid: 'BV1',
                  typeId: 1,
                  title: '洛天依',
                  author: 'UP',
                  coverUrl: '',
                  duration: '01:00',
                  playCountText: '1',
                  danmakuCountText: '0',
                  publishTimeText: '',
                  tagText: '',
                ),
              ],
              hasMore: true,
            ),
          },
          userResultsByKeyword: <String, SearchUserPageResult>{
            '洛天依': const SearchUserPageResult(
              items: <SearchUserItem>[
                SearchUserItem(
                  mid: 1,
                  name: '洛天依',
                  avatarUrl: '',
                  sign: '',
                  fansText: '1',
                  videoCountText: '1',
                  level: 6,
                ),
              ],
              hasMore: true,
            ),
          },
        );
        final ProviderContainer container = ProviderContainer(
          overrides: [
            biliSearchRepositoryProvider.overrideWithValue(repository),
            searchHistoryStoreProvider.overrideWithValue(
              _FakeSearchHistoryStore(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final ProviderSubscription<SearchState> subscription = container.listen(
          searchPageControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        final SearchPageController controller = container.read(
          searchPageControllerProvider.notifier,
        );

        await controller.changeType(type);
        await controller.submitSearch('洛天依');
        final SearchState firstPage = container.read(
          searchPageControllerProvider,
        );
        expect(firstPage.activeResultCount, 1);
        expect(firstPage.currentPage, 1);
        repository.searchError = StateError('page 2 failed');

        await controller.loadNextPage();

        final SearchState failedPage = container.read(
          searchPageControllerProvider,
        );
        expect(failedPage.results, firstPage.results);
        expect(failedPage.userResults, firstPage.userResults);
        expect(failedPage.currentPage, firstPage.currentPage);
        expect(failedPage.hasMore, isTrue);
        expect(failedPage.isLoading, isFalse);
        expect(failedPage.isLoadingMore, isFalse);
        expect(failedPage.errorMessage, isNull);
        expect(failedPage.loadMoreErrorMessage, contains('page 2 failed'));
        repository.searchError = null;
        repository.searchResultsByKeyword.clear();
        repository.userResultsByKeyword.clear();

        await controller.loadNextPage();

        final SearchState retriedPage = container.read(
          searchPageControllerProvider,
        );
        expect(retriedPage.results, firstPage.results);
        expect(retriedPage.userResults, firstPage.userResults);
        expect(retriedPage.currentPage, 2);
        expect(retriedPage.isLoadingMore, isFalse);
        expect(retriedPage.hasMore, isFalse);
        expect(retriedPage.errorMessage, isNull);
        expect(retriedPage.loadMoreErrorMessage, isNull);
        expect(retriedPage.videoResults.errorMessage, isNull);
        expect(retriedPage.userResultsPage.errorMessage, isNull);
        expect(
          type == SearchType.video
              ? repository.searchRequests
                    .map((request) => request.page)
                    .toList()
              : repository.userSearchPages,
          <int>[1, 2, 2],
        );
      },
    );

    test('${type.name} first-page failure stays a search error', () async {
      final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository()
        ..searchError = StateError('first page failed');
      final ProviderContainer container = ProviderContainer(
        overrides: [
          biliSearchRepositoryProvider.overrideWithValue(repository),
          searchHistoryStoreProvider.overrideWithValue(
            _FakeSearchHistoryStore(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final ProviderSubscription<SearchState> subscription = container.listen(
        searchPageControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final SearchPageController controller = container.read(
        searchPageControllerProvider.notifier,
      );

      await controller.changeType(type);
      await controller.submitSearch('洛天依');

      final SearchState state = container.read(searchPageControllerProvider);
      expect(state.results, isEmpty);
      expect(state.userResults, isEmpty);
      expect(state.currentPage, 0);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('first page failed'));
      expect(state.loadMoreErrorMessage, isNull);
    });

    test('${type.name} tab first-page failure stays a search error', () async {
      final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          biliSearchRepositoryProvider.overrideWithValue(repository),
          searchHistoryStoreProvider.overrideWithValue(
            _FakeSearchHistoryStore(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final ProviderSubscription<SearchState> subscription = container.listen(
        searchPageControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final SearchPageController controller = container.read(
        searchPageControllerProvider.notifier,
      );

      await controller.changeType(
        type == SearchType.video ? SearchType.up : SearchType.video,
      );
      await controller.submitSearch('洛天依');
      repository.searchError = StateError('tab first page failed');

      await controller.changeType(type);

      final SearchState state = container.read(searchPageControllerProvider);
      expect(state.activeResultCount, 0);
      expect(state.currentPage, 0);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('tab first page failed'));
      expect(state.loadMoreErrorMessage, isNull);
    });
  }

  test('ignores stale suggestion responses after newer query', () async {
    final _DeferredSuggestionsRepository repository =
        _DeferredSuggestionsRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        biliSearchRepositoryProvider.overrideWithValue(repository),
        searchHistoryStoreProvider.overrideWithValue(_FakeSearchHistoryStore()),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<SearchState> subscription = container.listen(
      searchPageControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final SearchPageController controller = container.read(
      searchPageControllerProvider.notifier,
    );

    controller.updateQuery('洛');
    controller.updateQuery('洛天依');

    repository.complete('洛天依', <String>['洛天依', '洛天依演唱会']);
    await Future<void>.delayed(Duration.zero);

    repository.complete('洛', <String>['洛阳']);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(searchPageControllerProvider);
    expect(state.query, '洛天依');
    expect(state.suggestions, <String>['洛天依', '洛天依演唱会']);
  });
}

class _FakeSearchHistoryStore implements SearchHistoryStore {
  List<String> savedKeywords = <String>[];
  bool wasCleared = false;

  @override
  List<String> load() => <String>[];

  @override
  Future<void> save(List<String> keywords) async {
    savedKeywords = keywords;
  }

  @override
  Future<void> clear() async {
    wasCleared = true;
  }
}

class _SearchRequest {
  const _SearchRequest({
    required this.keyword,
    required this.page,
    required this.sort,
  });

  final String keyword;
  final int page;
  final SearchSort sort;
}

class _FakeBiliSearchRepository implements BiliSearchRepository {
  _FakeBiliSearchRepository({
    this.searchResultsByKeyword = const <String, SearchPageResult>{},
    this.userResultsByKeyword = const <String, SearchUserPageResult>{},
    this.suggestionsByTerm = const <String, List<String>>{},
  });

  final Map<String, SearchPageResult> searchResultsByKeyword;
  final Map<String, SearchUserPageResult> userResultsByKeyword;
  final Map<String, List<String>> suggestionsByTerm;
  final List<_SearchRequest> searchRequests = <_SearchRequest>[];
  final List<String> userSearchRequests = <String>[];
  final List<int> userSearchPages = <int>[];
  Object? searchError;

  @override
  Future<SearchPageResult> searchVideos(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    searchRequests.add(
      _SearchRequest(keyword: keyword, page: page, sort: sort),
    );
    if (searchError != null) {
      throw searchError!;
    }
    return searchResultsByKeyword[keyword] ??
        SearchPageResult(page: page, hasMore: false);
  }

  @override
  Future<SearchPageResult> searchVideosAnonymously(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    return searchVideos(keyword, page: page, sort: sort);
  }

  @override
  Future<SearchUserPageResult> searchUsers(
    String keyword, {
    int page = 1,
  }) async {
    userSearchRequests.add(keyword);
    userSearchPages.add(page);
    if (searchError != null) {
      throw searchError!;
    }
    return userResultsByKeyword[keyword] ??
        SearchUserPageResult(page: page, hasMore: false);
  }

  @override
  Future<List<String>> fetchSuggestions(String term) async {
    return suggestionsByTerm[term] ?? <String>[];
  }
}

class _DeferredSuggestionsRepository extends _FakeBiliSearchRepository {
  final Map<String, Completer<List<String>>> _completers =
      <String, Completer<List<String>>>{};

  @override
  Future<List<String>> fetchSuggestions(String term) {
    return (_completers[term] ??= Completer<List<String>>()).future;
  }

  void complete(String term, List<String> suggestions) {
    final Completer<List<String>> completer = _completers[term] ??=
        Completer<List<String>>();
    if (!completer.isCompleted) {
      completer.complete(suggestions);
    }
  }
}
