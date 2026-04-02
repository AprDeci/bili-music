import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_page_result.freezed.dart';

@freezed
abstract class CommentPageResult with _$CommentPageResult {
  const factory CommentPageResult({
    @Default(<CommentItem>[]) List<CommentItem> items,
    @Default(<CommentItem>[]) List<CommentItem> hotItems,
    CommentItem? topItem,
    required int page,
    required int pageSize,
    required int totalCount,
    required bool hasMore,
    String? nextOffset,
    @Default(<CommentSort>[]) List<CommentSort> supportedSorts,
    String? sortTitle,
    @Default(false) bool isEnd,
    @Default(false) bool hasFolded,
    @Default(false) bool isFolded,
    @Default(false) bool isReadOnly,
    String? noticeText,
  }) = _CommentPageResult;
}
