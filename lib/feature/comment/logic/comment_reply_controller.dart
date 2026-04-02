import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_reply_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_reply_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_reply_controller.freezed.dart';
part 'comment_reply_controller.g.dart';

@freezed
abstract class CommentReplySheetArgs with _$CommentReplySheetArgs {
  const factory CommentReplySheetArgs({
    required CommentTarget target,
    required CommentItem rootItem,
  }) = _CommentReplySheetArgs;
}

@riverpod
class CommentReplyController extends _$CommentReplyController {
  static final AppLogger _logger = AppLogger('CommentReplyController');

  late final BiliCommentRepository _repository = ref.read(
    biliCommentRepositoryProvider,
  );

  @override
  CommentReplyState build(CommentReplySheetArgs args) {
    return CommentReplyState(target: args.target, rootItem: args.rootItem);
  }

  Future<void> loadInitial() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      loadMoreErrorMessage: null,
    );

    await _loadPage(page: 1, append: false);
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, loadMoreErrorMessage: null);
    await _loadPage(page: state.currentPage + 1, append: true);
  }

  Future<void> refresh() async {
    if (state.isLoading) {
      return;
    }
    await loadInitial();
  }

  Future<void> _loadPage({required int page, required bool append}) async {
    _logger.d(
      '_loadPage root=${state.rootItem.rpid} page=$page append=$append',
    );

    try {
      final CommentReplyPageResult result = await _repository
          .fetchChildComments(
            state.target,
            rootRpid: state.rootItem.rpid,
            page: page,
          );

      state = state.copyWith(
        rootItem: result.rootItem,
        items: append
            ? <CommentItem>[...state.items, ...result.items]
            : result.items,
        isLoading: false,
        isLoadingMore: false,
        currentPage: result.page,
        totalCount: result.totalCount,
        hasMore: result.hasMore,
        isReadOnly: result.isReadOnly,
        errorMessage: null,
        loadMoreErrorMessage: null,
      );
    } on Object catch (error) {
      _logger.e('load child comments failed', error);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: append ? state.errorMessage : error.toString(),
        loadMoreErrorMessage: append ? error.toString() : null,
      );
    }
  }
}
