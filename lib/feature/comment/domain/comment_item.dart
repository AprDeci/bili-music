import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_item.freezed.dart';

@freezed
abstract class CommentPicture with _$CommentPicture {
  const factory CommentPicture({
    required String imageUrl,
    int? width,
    int? height,
    int? sizeKb,
  }) = _CommentPicture;
}

@freezed
abstract class CommentItem with _$CommentItem {
  const CommentItem._();

  const factory CommentItem({
    required int rpid,
    required int oid,
    required int type,
    required int root,
    required int parent,
    required int replyCount,
    required int likeCount,
    required int action,
    required DateTime publishedAt,
    required String message,
    @Default(<CommentPicture>[]) List<CommentPicture> pictures,
    required String memberName,
    required String memberAvatarUrl,
    @Default(false) bool isTop,
    @Default(false) bool isHidden,
    @Default(<CommentItem>[]) List<CommentItem> replies,
  }) = _CommentItem;

  bool get isRoot => root == 0;
  bool get isLiked => action == 1;
}
