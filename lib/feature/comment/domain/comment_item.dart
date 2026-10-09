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

  // 幂等：已处于目标状态时原样返回，便于乐观更新反复套用。
  CommentItem withLike(bool liked) {
    if (isLiked == liked) {
      return this;
    }
    final int nextCount = liked ? likeCount + 1 : likeCount - 1;
    return copyWith(
      action: liked ? 1 : 0,
      likeCount: nextCount < 0 ? 0 : nextCount,
    );
  }
}
