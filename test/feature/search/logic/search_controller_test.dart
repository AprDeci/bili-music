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
    await Future<void>.delayed(
      SearchPageController.suggestionDebounce +
          const Duration(milliseconds: 100),
    );

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

    controller.updateQuery('洛天依');
    controller.loadSuggestions('洛');
    controller.loadSuggestions('洛天依');

    repository.complete('洛天依', <String>['洛天依', '洛天依演唱会']);
    await Future<void>.delayed(Duration.zero);

    repository.complete('洛', <String>['洛阳']);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(searchPageControllerProvider);
    expect(state.query, '洛天依');
    expect(state.suggestions, <String>['洛天依', '洛天依演唱会']);
  });

  test('debounces suggestion requests while typing', () async {
    final _FakeBiliSearchRepository repository = _FakeBiliSearchRepository();
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
    controller.updateQuery('洛天');
    controller.updateQuery('洛天依');

    expect(repository.suggestionRequests, isEmpty);
    await Future<void>.delayed(
      SearchPageController.suggestionDebounce +
          const Duration(milliseconds: 100),
    );

    expect(repository.suggestionRequests, <String>['洛天依']);
  });

  test('discards stale first page result after newer search', () async {
    final _DeferredSearchRepository repository = _DeferredSearchRepository();
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

    final Future<void> older = controller.submitSearch('旧');
    final Future<void> newer = controller.submitSearch('新');

    repository.complete(
      '新',
      SearchPageResult(items: <SearchResultItem>[_result('新结果')]),
    );
    await newer;
    repository.complete(
      '旧',
      SearchPageResult(
        items: <SearchResultItem>[_result('旧结果1'), _result('旧结果2')],
      ),
    );
    await older;

    final SearchState state = container.read(searchPageControllerProvider);
    expect(state.submittedQuery, '新');
    expect(state.results.map((SearchResultItem item) => item.title), <String>[
      '新结果',
    ]);
    expect(state.isLoading, isFalse);
  });
}

SearchResultItem _result(String title) {
  return SearchResultItem(
    aid: 1,
    bvid: 'BV1',
    typeId: 1,
    title: title,
    author: 'UP',
    coverUrl: '',
    duration: '03:00',
    playCountText: '1万',
    danmakuCountText: '100',
    publishTimeText: '2026-01-01',
    tagText: '音乐',
  );
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
  final List<String> suggestionRequests = <String>[];

  @override
  Future<SearchPageResult> searchVideos(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    searchRequests.add(
      _SearchRequest(keyword: keyword, page: page, sort: sort),
    );
    return searchResultsByKeyword[keyword] ??
        SearchPageResult(page: page, hasMore: false);
  }

  @override
  Future<SearchUserPageResult> searchUsers(
    String keyword, {
    int page = 1,
  }) async {
    userSearchRequests.add(keyword);
    return userResultsByKeyword[keyword] ??
        SearchUserPageResult(page: page, hasMore: false);
  }

  @override
  Future<List<String>> fetchSuggestions(String term) async {
    suggestionRequests.add(term);
    return suggestionsByTerm[term] ?? <String>[];
  }
}

class _DeferredSearchRepository extends _FakeBiliSearchRepository {
  final Map<String, Completer<SearchPageResult>> _completers =
      <String, Completer<SearchPageResult>>{};

  @override
  Future<SearchPageResult> searchVideos(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) {
    return (_completers[keyword] ??= Completer<SearchPageResult>()).future;
  }

  void complete(String keyword, SearchPageResult result) {
    final Completer<SearchPageResult> completer = _completers[keyword] ??=
        Completer<SearchPageResult>();
    if (!completer.isCompleted) {
      completer.complete(result);
    }
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
