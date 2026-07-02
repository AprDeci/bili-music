import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';

class FavoriteEntryGroup {
  const FavoriteEntryGroup({
    required this.videoKey,
    required this.parent,
    required this.items,
  });

  final String videoKey;
  final FavoriteEntry parent;
  final List<FavoriteEntry> items;

  bool get isMultiPart => items.length > 1;
}

List<FavoriteEntryGroup> groupFavoriteEntriesByVideo(
  List<FavoriteEntry> items,
) {
  final Map<String, List<FavoriteEntry>> groupedItems =
      <String, List<FavoriteEntry>>{};
  final List<String> orderedKeys = <String>[];

  for (final FavoriteEntry item in items) {
    final String key = favoriteEntryVideoKey(item);
    if (!groupedItems.containsKey(key)) {
      groupedItems[key] = <FavoriteEntry>[];
      orderedKeys.add(key);
    }
    groupedItems[key]!.add(item);
  }

  return orderedKeys
      .map((String key) {
        final List<FavoriteEntry> groupItems = List<FavoriteEntry>.of(
          groupedItems[key]!,
        )..sort(_compareFavoriteEntryParts);
        return FavoriteEntryGroup(
          videoKey: key,
          parent: groupItems.first,
          items: groupItems,
        );
      })
      .toList(growable: false);
}

List<FavoriteEntry> orderFavoriteEntriesForDisplay(List<FavoriteEntry> items) {
  final List<FavoriteEntry> orderedItems = <FavoriteEntry>[];
  for (final FavoriteEntryGroup group in groupFavoriteEntriesByVideo(items)) {
    orderedItems.addAll(group.items);
  }
  return orderedItems;
}

String favoriteEntryVideoKey(FavoriteEntry item) {
  if (item.bvid.isNotEmpty) {
    return 'bvid:${item.bvid}';
  }
  if (item.aid > 0) {
    return 'aid:${item.aid}';
  }
  return item.itemId;
}

int _compareFavoriteEntryParts(FavoriteEntry a, FavoriteEntry b) {
  final int? aPage = a.page;
  final int? bPage = b.page;
  if (aPage != null && bPage != null && aPage != bPage) {
    return aPage.compareTo(bPage);
  }
  if (aPage != null && bPage == null) {
    return -1;
  }
  if (aPage == null && bPage != null) {
    return 1;
  }
  return a.createdAt.compareTo(b.createdAt);
}
