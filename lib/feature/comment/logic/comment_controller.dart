import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_controller.g.dart';

@riverpod
class CommentController extends _$CommentController {
  static final AppLogger _logger = AppLogger('CommentController');

  late final BiliCommentRepository _repository = ref.read(
    biliCommentRepositoryProvider,
  );

  @override
  CommentState build(CommentTarget target) {
    _logger.d('build target oid=${target.oid} type=${target.type}');
    return CommentState(target: target);
  }

  Future<void> loadInitial() async {
    _logger.d(
      'loadInitial start '
      'oid=${state.target.oid} '
      'sort=${state.sort} '
      'isLoading=${state.isLoading}',
    );

    if (state.isLoading) {
      _logger.d('loadInitial skipped: already loading');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: null,
      loadMoreErrorMessage: null,
    );

    await _loadPage(resetItems: true, page: 1, preserveExistingItems: false);
  }

  Future<void> refresh() async {
    _logger.d(
      'refresh start '
      'oid=${state.target.oid} '
      'sort=${state.sort} '
      'isLoading=${state.isLoading} '
      'isRefreshing=${state.isRefreshing}',
    );

    if (state.isLoading || state.isRefreshing) {
      _logger.d('refresh skipped');
      return;
    }

    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      errorMessage: null,
      loadMoreErrorMessage: null,
    );

    await _loadPage(resetItems: true, page: 1, preserveExistingItems: true);
  }

  Future<void> loadNextPage() async {
    _logger.d(
      'loadNextPage start '
      'oid=${state.target.oid} '
      'sort=${state.sort} '
      'currentPage=${state.currentPage} '
      'hasMore=${state.hasMore} '
      'isLoading=${state.isLoading} '
      'isRefreshing=${state.isRefreshing} '
      'isLoadingMore=${state.isLoadingMore}',
    );

    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      _logger.d('loadNextPage skipped');
      return;
    }

    final int nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, loadMoreErrorMessage: null);

    try {
      final CommentPageResult page = await _repository.fetchRootComments(
        state.target,
        page: nextPage,
        nextOffset: state.nextOffset,
        sort: state.sort,
        includeHot: false,
      );

      state = state.copyWith(
        items: <CommentItem>[...state.items, ...page.items],
        hotItems: page.hotItems,
        topItem: page.topItem ?? state.topItem,
        isLoadingMore: false,
        currentPage: page.page,
        hasMore: page.hasMore,
        nextOffset: page.nextOffset,
        supportedSorts: page.supportedSorts,
        sortTitle: page.sortTitle,
        isEnd: page.isEnd,
        hasFolded: page.hasFolded,
        isFolded: page.isFolded,
        isReadOnly: page.isReadOnly,
        noticeText: page.noticeText,
        loadMoreErrorMessage: null,
      );

      _logger.d(
        'loadNextPage success '
        'requestedPage=$nextPage '
        'receivedPage=${page.page} '
        'addedItems=${page.items.length} '
        'totalItems=${state.items.length} '
        'hots=${state.hotItems.length} '
        'top=${state.topItem != null} '
        'hasMore=${state.hasMore}',
      );
    } on Object catch (error) {
      _logger.e('loadNextPage failed', error);
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreErrorMessage: error.toString(),
      );
    }
  }

  Future<void> changeSort(CommentSort sort) async {
    _logger.d('changeSort from=${state.sort} to=$sort');

    if (state.sort == sort) {
      _logger.d('changeSort skipped: same sort');
      return;
    }

    state = state.copyWith(sort: sort);
    await refresh();
  }

  Future<void> _loadPage({
    required bool resetItems,
    required int page,
    required bool preserveExistingItems,
  }) async {
    _logger.d(
      '_loadPage start '
      'oid=${state.target.oid} '
      'page=$page '
      'sort=${state.sort} '
      'resetItems=$resetItems '
      'preserveExistingItems=$preserveExistingItems',
    );

    try {
      final CommentPageResult result = await _repository.fetchRootComments(
        state.target,
        page: page,
        nextOffset: page == 1 ? null : state.nextOffset,
        sort: state.sort,
        includeHot: page == 1,
      );

      state = state.copyWith(
        items: result.items,
        hotItems: result.hotItems,
        topItem: result.topItem,
        supportedSorts: result.supportedSorts,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        currentPage: result.page,
        hasMore: result.hasMore,
        nextOffset: result.nextOffset,
        sortTitle: result.sortTitle,
        isEnd: result.isEnd,
        hasFolded: result.hasFolded,
        isFolded: result.isFolded,
        isReadOnly: result.isReadOnly,
        noticeText: result.noticeText,
        errorMessage: null,
        loadMoreErrorMessage: null,
      );

      _logger.d(
        '_loadPage success '
        'page=${result.page} '
        'items=${result.items.length} '
        'hots=${result.hotItems.length} '
        'top=${result.topItem != null} '
        'hasMore=${result.hasMore} '
        'totalStateItems=${state.items.length}',
      );
    } on Object catch (error) {
      _logger.e('_loadPage failed page=$page sort=${state.sort}', error);
      state = state.copyWith(
        items: resetItems && !preserveExistingItems
            ? const <CommentItem>[]
            : state.items,
        hotItems: resetItems && !preserveExistingItems
            ? const <CommentItem>[]
            : state.hotItems,
        topItem: resetItems && !preserveExistingItems ? null : state.topItem,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        currentPage: resetItems && !preserveExistingItems
            ? 0
            : state.currentPage,
        hasMore: resetItems && !preserveExistingItems ? false : state.hasMore,
        nextOffset: resetItems && !preserveExistingItems ? null : state.nextOffset,
        errorMessage: error.toString(),
        loadMoreErrorMessage: null,
      );
    }
  }
}
