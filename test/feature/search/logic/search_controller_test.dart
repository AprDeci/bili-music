import 'dart:async';

import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/data/search_history_store.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
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
    this.suggestionsByTerm = const <String, List<String>>{},
  });

  final Map<String, SearchPageResult> searchResultsByKeyword;
  final Map<String, List<String>> suggestionsByTerm;
  final List<_SearchRequest> searchRequests = <_SearchRequest>[];

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
