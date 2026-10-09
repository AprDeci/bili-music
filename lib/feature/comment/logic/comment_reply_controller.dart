import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_reply_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_reply_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_controller.dart';
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

  final Set<int> _likeInFlight = <int>{};

  @override
  CommentReplyState build(CommentReplySheetArgs args) {
    return CommentReplyState(target: args.target, rootItem: args.rootItem);
  }

  Future<void> toggleLike(CommentItem item) async {
    if (_likeInFlight.contains(item.rpid)) {
      return;
    }

    final bool liked = !item.isLiked;
    _likeInFlight.add(item.rpid);
    applyLocalUpdate(
      item.rpid,
      (CommentItem comment) => comment.withLike(liked),
    );

    try {
      await _repository.likeComment(
        state.target,
        rpid: item.rpid,
        liked: liked,
      );
      _syncMainList(
        item.rpid,
        (CommentItem comment) => comment.withLike(liked),
      );
      _logger.d('toggleLike success rpid=${item.rpid} liked=$liked');
    } on Object catch (error) {
      _logger.e('toggleLike failed rpid=${item.rpid}', error);
      applyLocalUpdate(
        item.rpid,
        (CommentItem comment) => comment.withLike(item.isLiked),
      );
      ToastUtil.show(commentErrorText(error));
    } finally {
      _likeInFlight.remove(item.rpid);
    }
  }

  /// 在楼中楼里发表回复；[replyTo] 为空时回复楼主，否则回复该条回复。
  Future<bool> submitReply(String message, {CommentItem? replyTo}) async {
    final String content = message.trim();
    if (content.isEmpty) {
      return false;
    }

    final int rootRpid = state.rootItem.rpid;
    try {
      await _repository.addComment(
        state.target,
        message: content,
        root: rootRpid,
        parent: replyTo?.rpid ?? rootRpid,
      );

      _syncMainList(
        rootRpid,
        (CommentItem comment) =>
            comment.copyWith(replyCount: comment.replyCount + 1),
      );
      ToastUtil.show('回复已发布');
      // 楼中楼顺序由服务端决定，重拉第一页而不是猜插入位置。
      await loadInitial();
      return true;
    } on Object catch (error) {
      _logger.e('submitReply failed', error);
      ToastUtil.show(commentErrorText(error));
      return false;
    }
  }

  void applyLocalUpdate(
    int rpid,
    CommentItem Function(CommentItem item) update,
  ) {
    state = state.copyWith(
      rootItem: state.rootItem.rpid == rpid
          ? update(state.rootItem)
          : state.rootItem,
      items: state.items
          .map((CommentItem item) => item.rpid == rpid ? update(item) : item)
          .toList(),
    );
  }

  void _syncMainList(int rpid, CommentItem Function(CommentItem item) update) {
    ref
        .read(commentControllerProvider(state.target).notifier)
        .applyLocalUpdate(rpid, update);
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
