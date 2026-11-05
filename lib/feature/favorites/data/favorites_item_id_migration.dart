import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:hive_ce/hive.dart';

String canonicalFavoriteItemId({
  required int aid,
  required String bvid,
  int? cid,
}) {
  if (cid != null && cid > 0) {
    return bvid.isNotEmpty ? 'bvid:$bvid:cid:$cid' : 'aid:$aid:cid:$cid';
  }
  return bvid.isNotEmpty ? 'bvid:$bvid' : 'aid:$aid';
}

Future<int> migrateFavoriteItemIds({
  required Box<FavoriteEntry> entriesBox,
  required Box<FavoriteMembership> membershipsBox,
}) async {
  final Map<String, FavoriteEntry> sourceEntries = <String, FavoriteEntry>{};
  for (final String key in entriesBox.keys.whereType<String>()) {
    final FavoriteEntry? entry = entriesBox.get(key);
    if (entry != null) {
      sourceEntries[key] = entry;
    }
  }
  if (sourceEntries.isEmpty && membershipsBox.isEmpty) {
    return 0;
  }

  final Map<String, String> idMapping = <String, String>{};
  final Map<String, FavoriteEntry> normalizedEntries =
      <String, FavoriteEntry>{};
  bool entriesChanged = false;

  for (final MapEntry<String, FavoriteEntry> item in sourceEntries.entries) {
    final String oldId = item.key;
    final FavoriteEntry entry = item.value;
    final String canonical = canonicalFavoriteItemId(
      aid: entry.aid,
      bvid: entry.bvid,
      cid: entry.cid,
    );
    idMapping[oldId] = canonical;
    if (oldId != canonical || entry.itemId != canonical) {
      entriesChanged = true;
    }
    final FavoriteEntry candidate = entry.itemId == canonical
        ? entry
        : entry.copyWith(itemId: canonical);
    normalizedEntries[canonical] = _mergeEntries(
      normalizedEntries[canonical],
      candidate,
    );
  }

  final Map<String, FavoriteMembership> normalizedMemberships =
      <String, FavoriteMembership>{};
  bool membershipsChanged = false;

  for (final FavoriteMembership membership in membershipsBox.values) {
    final String itemId = idMapping[membership.itemId] ?? membership.itemId;
    final FavoriteMembership candidate = FavoriteMembership(
      id: FavoriteMembership.membershipId(
        collectionId: membership.collectionId,
        itemId: itemId,
      ),
      collectionId: membership.collectionId,
      itemId: itemId,
      addedAt: membership.addedAt,
    );
    final FavoriteMembership? existing = normalizedMemberships[candidate.id];
    if (candidate.id != membership.id ||
        candidate.itemId != membership.itemId ||
        existing != null) {
      membershipsChanged = true;
    }
    normalizedMemberships[candidate.id] = existing == null
        ? candidate
        : existing.copyWith(
            addedAt: existing.addedAt.isBefore(candidate.addedAt)
                ? existing.addedAt
                : candidate.addedAt,
          );
  }

  if (!entriesChanged && !membershipsChanged) {
    return 0;
  }

  final List<String> obsoleteMembershipKeys = membershipsBox.keys
      .whereType<String>()
      .where((String key) => !normalizedMemberships.containsKey(key))
      .toList(growable: false);
  final List<String> obsoleteEntryKeys = sourceEntries.keys
      .where((String key) => !normalizedEntries.containsKey(key))
      .toList(growable: false);

  await entriesBox.putAll(normalizedEntries);
  await entriesBox.flush();
  await membershipsBox.putAll(normalizedMemberships);
  await membershipsBox.flush();
  await membershipsBox.deleteAll(obsoleteMembershipKeys);
  await membershipsBox.flush();
  await entriesBox.deleteAll(obsoleteEntryKeys);
  await entriesBox.flush();
  return normalizedEntries.length + normalizedMemberships.length;
}

FavoriteEntry _mergeEntries(FavoriteEntry? current, FavoriteEntry candidate) {
  if (current == null) {
    return candidate;
  }
  final FavoriteEntry preferred =
      (current.cid != null && current.cid! > 0) || candidate.cid == null
      ? current
      : candidate;
  final FavoriteEntry other = identical(preferred, current)
      ? candidate
      : current;
  return preferred.copyWith(
    ownerMid: preferred.ownerMid ?? other.ownerMid,
    cid: preferred.cid ?? other.cid,
    page: preferred.page ?? other.page,
    pageTitle: preferred.pageTitle ?? other.pageTitle,
    durationText: preferred.durationText ?? other.durationText,
    coverUrl: preferred.coverUrl.isNotEmpty
        ? preferred.coverUrl
        : other.coverUrl,
    createdAt: preferred.createdAt.isBefore(other.createdAt)
        ? preferred.createdAt
        : other.createdAt,
    updatedAt: preferred.updatedAt.isAfter(other.updatedAt)
        ? preferred.updatedAt
        : other.updatedAt,
  );
}
