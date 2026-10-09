import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_reply_state.freezed.dart';

@freezed
abstract class CommentReplyState with _$CommentReplyState {
  const factory CommentReplyState({
    required CommentTarget target,
    required CommentItem rootItem,
    @Default(<CommentItem>[]) List<CommentItem> items,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default(0) int currentPage,
    @Default(0) int totalCount,
    @Default(false) bool isReadOnly,
    String? errorMessage,
    String? loadMoreErrorMessage,
  }) = _CommentReplyState;
}
