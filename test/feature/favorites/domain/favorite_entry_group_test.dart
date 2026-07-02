import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupFavoriteEntriesByVideo', () {
    test('groups multipart entries by video and sorts by page', () {
      final DateTime now = DateTime(2026);
      final FavoriteEntry part2 = _entry(
        itemId: 'bvid:BV1:cid:2',
        bvid: 'BV1',
        cid: 2,
        page: 2,
        pageTitle: 'Part 2',
        createdAt: now,
      );
      final FavoriteEntry part1 = _entry(
        itemId: 'bvid:BV1:cid:1',
        bvid: 'BV1',
        cid: 1,
        page: 1,
        pageTitle: 'Part 1',
        createdAt: now.add(const Duration(seconds: 1)),
      );
      final FavoriteEntry single = _entry(
        itemId: 'bvid:BV2',
        bvid: 'BV2',
        createdAt: now.add(const Duration(seconds: 2)),
      );

      final List<FavoriteEntryGroup> groups = groupFavoriteEntriesByVideo(
        <FavoriteEntry>[part2, part1, single],
      );

      expect(groups, hasLength(2));
      expect(groups.first.isMultiPart, isTrue);
      expect(groups.first.items, <FavoriteEntry>[part1, part2]);
      expect(groups.last.isMultiPart, isFalse);
      expect(groups.last.items.single, single);
      expect(
        orderFavoriteEntriesForDisplay(<FavoriteEntry>[part2, part1, single]),
        <FavoriteEntry>[part1, part2, single],
      );
    });
  });
}

FavoriteEntry _entry({
  required String itemId,
  required String bvid,
  required DateTime createdAt,
  int? cid,
  int? page,
  String? pageTitle,
}) {
  return FavoriteEntry(
    itemId: itemId,
    aid: 1,
    bvid: bvid,
    title: 'Video',
    author: 'Author',
    coverUrl: 'https://example.com/cover.jpg',
    cid: cid,
    page: page,
    pageTitle: pageTitle,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
