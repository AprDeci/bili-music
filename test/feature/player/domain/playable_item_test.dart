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
  });
}

PlayableItem _item({required String title, String? pageTitle}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BVTEST123',
    title: title,
    author: 'author',
    coverUrl: 'https://example.com/cover.jpg',
    pageTitle: pageTitle,
  );
}
