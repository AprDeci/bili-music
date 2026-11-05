import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_state.freezed.dart';

@freezed
abstract class CommentState with _$CommentState {
  const CommentState._();

  const factory CommentState({
    required CommentTarget target,
    @Default(CommentSort.time) CommentSort sort,
    @Default(PagedState<CommentItem>()) PagedState<CommentItem> mainComments,
    @Default(<CommentItem>[]) List<CommentItem> hotItems,
    @Default(<CommentSort>[]) List<CommentSort> supportedSorts,
    CommentItem? topItem,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(0) int total,
    String? nextOffset,
    String? sortTitle,
    @Default(false) bool isEnd,
    @Default(false) bool hasFolded,
    @Default(false) bool isFolded,
    @Default(false) bool isReadOnly,
    String? noticeText,
    String? errorMessage,
    String? loadMoreErrorMessage,
  }) = _CommentState;

  List<CommentItem> get items => mainComments.items;

  bool get isLoadingMore => mainComments.isLoadingMore;

  int get currentPage => mainComments.page;

  bool get hasMore => mainComments.hasMore;
}
