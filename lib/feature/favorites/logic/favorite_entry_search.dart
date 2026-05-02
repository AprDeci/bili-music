import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';

List<FavoriteEntry> filterFavoriteEntries(
  List<FavoriteEntry> items,
  String query,
) {
  final String normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return items;
  }

  return items
      .where(
        (FavoriteEntry item) =>
            _matchesFavoriteEntryQuery(item, normalizedQuery),
      )
      .toList(growable: false);
}

bool _matchesFavoriteEntryQuery(FavoriteEntry item, String normalizedQuery) {
  return item.title.toLowerCase().contains(normalizedQuery) ||
      item.author.toLowerCase().contains(normalizedQuery) ||
      (item.pageTitle?.toLowerCase().contains(normalizedQuery) ?? false);
}
