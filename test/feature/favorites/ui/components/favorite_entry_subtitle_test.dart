import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:flutter_test/flutter_test.dart';

FavoriteEntry _entry({int? page, String? pageTitle}) {
  return FavoriteEntry(
    itemId: 'id',
    aid: 1,
    bvid: 'BV1',
    title: 'title',
    author: 'UP主',
    coverUrl: '',
    page: page,
    pageTitle: pageTitle,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('buildFavoriteTileSubtitle', () {
    test('无分P时显示UP主', () {
      expect(buildFavoriteTileSubtitle(_entry(page: 1)), 'UP主');
      expect(buildFavoriteTileSubtitle(_entry()), 'UP主');
    });

    test('有分P时隐藏UP主', () {
      expect(
        buildFavoriteTileSubtitle(_entry(page: 2, pageTitle: '分P标题')),
        'P2 · 分P标题',
      );
    });

    test('分P标题恰好13字不截断', () {
      const String title = '一二三四五六七八九十一二三';
      expect(title.length, 13);
      expect(
        buildFavoriteTileSubtitle(_entry(page: 2, pageTitle: title)),
        'P2 · $title',
      );
    });

    test('分P标题超过13字截断并加省略号', () {
      const String title = '一二三四五六七八九十一二三四';
      expect(title.length, 14);
      expect(
        buildFavoriteTileSubtitle(_entry(page: 2, pageTitle: title)),
        'P2 · 一二三四五六七八九十一二三...',
      );
    });
  });
}
