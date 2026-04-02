import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_state.freezed.dart';

@freezed
abstract class CommentState with _$CommentState {
  const factory CommentState({
    required CommentTarget target,
    @Default(CommentSort.time) CommentSort sort,
    @Default(<CommentItem>[]) List<CommentItem> items,
    @Default(<CommentItem>[]) List<CommentItem> hotItems,
    CommentItem? topItem,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingMore,
    @Default(0) int currentPage,
    @Default(false) bool hasMore,
    @Default(false) bool isReadOnly,
    String? noticeText,
    String? errorMessage,
    String? loadMoreErrorMessage,
  }) = _CommentState;
}
