enum CommentSort { time, like, reply }

extension CommentSortExtension on CommentSort {
  int get apiValue {
    switch (this) {
      case CommentSort.time:
        return 0;
      case CommentSort.like:
        return 1;
      case CommentSort.reply:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case CommentSort.time:
        return '按时间排序';
      case CommentSort.like:
        return '按点赞数排序';
      case CommentSort.reply:
        return '按回复数排序';
    }
  }
}
