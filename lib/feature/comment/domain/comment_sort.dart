enum CommentSort { time, like, hybrid }

extension CommentSortExtension on CommentSort {
  String get label {
    switch (this) {
      case CommentSort.time:
        return '最新';
      case CommentSort.like:
        return '最热';
      case CommentSort.hybrid:
        return '综合';
    }
  }
}
