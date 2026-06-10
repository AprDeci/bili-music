enum SearchType { video, up }

extension SearchTypeExtension on SearchType {
  String get label {
    switch (this) {
      case SearchType.video:
        return '视频';
      case SearchType.up:
        return 'UP主';
    }
  }

  String get apiValue {
    switch (this) {
      case SearchType.video:
        return 'video';
      case SearchType.up:
        return 'bili_user';
    }
  }
}
