import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';

const int _maxPartTitleChars = 13;

String buildFavoriteEntrySubtitle(FavoriteEntry item) {
  final List<String> segments = <String>[item.author];
  final int? page = item.page == 1 ? null : item.page;
  final String pageTitle = page != null ? item.pageTitle?.trim() ?? '' : '';

  if (page != null && page > 0) {
    segments.add('P$page');
  }
  if (pageTitle.isNotEmpty) {
    segments.add(pageTitle);
  }
  // if (item.durationText != null && item.durationText!.isNotEmpty) {
  //   segments.add(item.durationText!);
  // }

  return segments.join(' · ');
}

// 移动端构建收藏项Subtitle
String buildFavoriteTileSubtitle(FavoriteEntry item) {
  final int? page = item.page == 1 ? null : item.page;
  if (page == null || page <= 0) {
    return item.author;
  }
  final List<String> segments = <String>['P$page'];
  final String pageTitle = item.pageTitle?.trim() ?? '';
  if (pageTitle.isNotEmpty) {
    segments.add(
      pageTitle.length > _maxPartTitleChars
          ? '${pageTitle.substring(0, _maxPartTitleChars)}...'
          : pageTitle,
    );
  }
  return segments.join(' · ');
}
