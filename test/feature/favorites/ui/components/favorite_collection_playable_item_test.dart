import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection playback mappings carry kind and collection context', () {
    final DateTime now = DateTime(2026);
    final FavoriteEntry entry = FavoriteEntry(
      itemId: 'bvid:BV1:cid:10',
      aid: 1,
      bvid: 'BV1',
      title: 'original title',
      author: 'UP',
      coverUrl: 'original cover',
      cid: 10,
      page: 2,
      pageTitle: 'part two',
      createdAt: now,
      updatedAt: now,
    );
    for (final CollectionKind kind in CollectionKind.values) {
      final FavoriteCollection collection = FavoriteCollection(
        id: 'collection',
        name: 'collection',
        kind: kind,
        createdAt: now,
        updatedAt: now,
      );
      final item = favoriteCollectionPlayableItem(entry, collection);
      expect(item.kind, kind);
      expect(item.collectionId, collection.id);
      expect(item.stableId, entry.toPlayableItem().stableId);
      expect(item.contentId, entry.contentId);
      expect(item.title, entry.title);
      expect(item.coverUrl, entry.coverUrl);
      expect(item.page, 2);
      expect(item.pageTitle, 'part two');
    }
  });
}
