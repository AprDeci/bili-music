enum CommentSortType { time, like, reply }

extension CommentSortTypeExtension on CommentSortType {
  int get apiValue {
    switch (this) {
      case CommentSortType.time:
        return 0;
      case CommentSortType.like:
        return 1;
      case CommentSortType.reply:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case CommentSortType.time:
        return '按时间排序';
      case CommentSortType.like:
        return '按点赞数排序';
      case CommentSortType.reply:
        return '按回复数排序';
    }
  }
}
