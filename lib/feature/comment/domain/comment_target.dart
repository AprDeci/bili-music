import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_target.freezed.dart';

@freezed
abstract class CommentTarget with _$CommentTarget {
  const CommentTarget._();

  const factory CommentTarget({
    required int oid,
    required int type,
    int? aid,
    String? bvid,
    String? title,
    String? coverUrl,
  }) = _CommentTarget;

  factory CommentTarget.video({
    required int aid,
    String? bvid,
    String? title,
    String? coverUrl,
  }) {
    return CommentTarget(
      oid: aid,
      type: 1,
      aid: aid,
      bvid: bvid,
      title: title,
      coverUrl: coverUrl,
    );
  }

  bool get isVideo => type == 1;
}
