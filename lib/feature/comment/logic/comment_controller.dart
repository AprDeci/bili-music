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
  late final BiliCommentRepository _repository = ref.read(
    biliCommentRepositoryProvider,
  );

  @override
  CommentState build(CommentTarget target) {
    return CommentState(target: target);
  }

  Future<void> loadInitial() async {
    if (state.isLoading) {
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
    if (state.isLoading || state.isRefreshing) {
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
    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final int nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, loadMoreErrorMessage: null);

    try {
      final CommentPageResult page = await _repository.fetchRootComments(
        state.target,
        page: nextPage,
        sort: state.sort,
      );

      state = state.copyWith(
        items: <CommentItem>[...state.items, ...page.items],
        isLoadingMore: false,
        currentPage: page.page,
        hasMore: page.hasMore,
        isReadOnly: page.isReadOnly,
        noticeText: page.noticeText,
        loadMoreErrorMessage: null,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreErrorMessage: error.toString(),
      );
    }
  }

  Future<void> changeSort(CommentSort sort) async {
    if (state.sort == sort) {
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
    try {
      final CommentPageResult result = await _repository.fetchRootComments(
        state.target,
        page: page,
        sort: state.sort,
      );

      state = state.copyWith(
        items: result.items,
        hotItems: result.hotItems,
        topItem: result.topItem,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        currentPage: result.page,
        hasMore: result.hasMore,
        isReadOnly: result.isReadOnly,
        noticeText: result.noticeText,
        errorMessage: null,
        loadMoreErrorMessage: null,
      );
    } on Object catch (error) {
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
        errorMessage: error.toString(),
        loadMoreErrorMessage: null,
      );
    }
  }
}
