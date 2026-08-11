import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';

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
