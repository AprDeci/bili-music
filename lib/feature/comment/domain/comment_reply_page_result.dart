import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_reply_page_result.freezed.dart';

@freezed
abstract class CommentReplyPageResult with _$CommentReplyPageResult {
  const factory CommentReplyPageResult({
    required CommentItem rootItem,
    @Default(<CommentItem>[]) List<CommentItem> items,
    required int page,
    required int pageSize,
    required int totalCount,
    required bool hasMore,
    @Default(false) bool isReadOnly,
  }) = _CommentReplyPageResult;
}
