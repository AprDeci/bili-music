enum SearchSort { comprehensive, newest, mostFavorite }

extension SearchSortExtension on SearchSort {
  String get label {
    switch (this) {
      case SearchSort.comprehensive:
        return '综合';
      case SearchSort.newest:
        return '最新发布';
      case SearchSort.mostFavorite:
        return '最多收藏';
    }
  }

  String get apiValue {
    switch (this) {
      case SearchSort.comprehensive:
        return 'totalrank';
      case SearchSort.newest:
        return 'pubdate';
      case SearchSort.mostFavorite:
        return 'stow';
    }
  }
}
