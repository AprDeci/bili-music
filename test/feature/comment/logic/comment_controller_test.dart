import 'dart:async';

import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const CommentTarget _target = CommentTarget(
  oid: 1,
  type: 1,
  aid: 1,
  title: '测试视频',
);

void main() {
  test('切换排序会用新排序重新加载首屏', () async {
    final _FakeCommentRepository repository = _FakeCommentRepository(
      results: <CommentSort, CommentPageResult>{
        CommentSort.time: _page(page: 1, sort: CommentSort.time),
        CommentSort.like: _page(page: 1, sort: CommentSort.like),
      },
    );
    final ProviderContainer container = _container(repository);
    addTearDown(container.dispose);
    final ProviderSubscription<CommentState> subscription = container.listen(
      commentControllerProvider(_target),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final CommentController controller = container.read(
      commentControllerProvider(_target).notifier,
    );

    await controller.loadInitial();
    await controller.changeSort(CommentSort.like);

    final CommentState state = container.read(
      commentControllerProvider(_target),
    );
    expect(repository.requestedSorts, <CommentSort>[
      CommentSort.time,
      CommentSort.like,
    ]);
    expect(state.sort, CommentSort.like);
    expect(state.currentPage, 1);
    expect(state.isRefreshing, isFalse);
  });

  test('保留服务端返回的完整排序列表', () async {
    const List<CommentSort> sorts = <CommentSort>[
      CommentSort.hybrid,
      CommentSort.time,
      CommentSort.like,
    ];
    final _FakeCommentRepository repository = _FakeCommentRepository(
      results: <CommentSort, CommentPageResult>{
        CommentSort.time: _page(page: 1, sort: CommentSort.time, sorts: sorts),
      },
    );
    final ProviderContainer container = _container(repository);
    addTearDown(container.dispose);
    final ProviderSubscription<CommentState> subscription = container.listen(
      commentControllerProvider(_target),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final CommentController controller = container.read(
      commentControllerProvider(_target).notifier,
    );

    await controller.loadInitial();

    expect(
      container.read(commentControllerProvider(_target)).supportedSorts,
      sorts,
    );
  });

  test('快速切换排序时丢弃旧排序的迟到响应', () async {
    final _FakeCommentRepository repository = _FakeCommentRepository(
      deferred: true,
    );
    final ProviderContainer container = _container(repository);
    addTearDown(container.dispose);
    final ProviderSubscription<CommentState> subscription = container.listen(
      commentControllerProvider(_target),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final CommentController controller = container.read(
      commentControllerProvider(_target).notifier,
    );

    final Future<void> older = controller.changeSort(CommentSort.like);
    final Future<void> newer = controller.changeSort(CommentSort.hybrid);

    repository.complete(
      CommentSort.hybrid,
      _page(page: 2, sort: CommentSort.hybrid),
    );
    await newer;
    repository.complete(
      CommentSort.like,
      _page(page: 5, sort: CommentSort.like),
    );
    await older;

    final CommentState state = container.read(
      commentControllerProvider(_target),
    );
    expect(state.sort, CommentSort.hybrid);
    expect(state.currentPage, 2);
    expect(state.isRefreshing, isFalse);
  });
}

ProviderContainer _container(_FakeCommentRepository repository) {
  return ProviderContainer(
    overrides: [biliCommentRepositoryProvider.overrideWithValue(repository)],
  );
}

CommentPageResult _page({
  required int page,
  required CommentSort sort,
  bool hasMore = false,
  List<CommentSort> sorts = const <CommentSort>[
    CommentSort.hybrid,
    CommentSort.time,
    CommentSort.like,
  ],
}) {
  return CommentPageResult(
    page: page,
    pageSize: 20,
    totalCount: 0,
    hasMore: hasMore,
    supportedSorts: sorts,
    sortTitle: sort.label,
  );
}

class _FakeCommentRepository implements BiliCommentRepository {
  _FakeCommentRepository({
    Map<CommentSort, CommentPageResult>? results,
    this.deferred = false,
  }) : results = results ?? <CommentSort, CommentPageResult>{};

  final Map<CommentSort, CommentPageResult> results;
  final bool deferred;
  final List<CommentSort> requestedSorts = <CommentSort>[];
  final Map<CommentSort, Completer<CommentPageResult>> _completers =
      <CommentSort, Completer<CommentPageResult>>{};

  @override
  Future<CommentPageResult> fetchRootComments(
    CommentTarget target, {
    int page = 1,
    String? nextOffset,
    CommentSort sort = CommentSort.time,
    bool includeHot = true,
  }) {
    requestedSorts.add(sort);
    if (deferred) {
      return (_completers[sort] ??= Completer<CommentPageResult>()).future;
    }
    return Future<CommentPageResult>.value(
      results[sort] ?? _page(page: page, sort: sort),
    );
  }

  void complete(CommentSort sort, CommentPageResult result) {
    final Completer<CommentPageResult> completer = _completers[sort] ??=
        Completer<CommentPageResult>();
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
