import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayableItem', () {
    test('lyricSearchTitles prefers page title before video title', () {
      final PlayableItem item = _item(
        title: 'Video Title',
        pageTitle: 'Part Title',
      );

      expect(item.lyricSearchTitles, <String>['Part Title', 'Video Title']);
    });

    test('lyricSearchTitles falls back to video title', () {
      final PlayableItem item = _item(title: 'Video Title', pageTitle: '   ');

      expect(item.lyricSearchTitles, <String>['Video Title']);
    });

    test('lyricSearchTitles removes duplicate video title', () {
      final PlayableItem item = _item(
        title: 'Same Title',
        pageTitle: 'Same Title',
      );

      expect(item.lyricSearchTitles, <String>['Same Title']);
    });

    test('content identity ignores cid and normalizes the first page', () {
      final PlayableItem withCid = _item(title: 'Video Title', cid: 10);
      final PlayableItem withoutCid = _item(title: 'Video Title', page: 1);

      expect(withCid.contentId, 'bvid:BVTEST123:page:1');
      expect(withCid.contentId, withoutCid.contentId);
      expect(
        withCid.matchesContent(aid: 1, bvid: 'BVTEST123', page: 1),
        isTrue,
      );
    });

    test('content identity keeps pages separate', () {
      final PlayableItem item = _item(title: 'Part 2', cid: 20, page: 2);

      expect(item.contentId, 'bvid:BVTEST123:page:2');
      expect(item.matchesContent(aid: 1, bvid: 'BVTEST123', page: 1), isFalse);
    });
  });
}

PlayableItem _item({
  required String title,
  String? pageTitle,
  int? cid,
  int? page,
}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BVTEST123',
    title: title,
    author: 'author',
    coverUrl: 'https://example.com/cover.jpg',
    cid: cid,
    page: page,
    pageTitle: pageTitle,
  );
}
