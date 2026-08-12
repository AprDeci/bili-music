import 'package:bilimusic/feature/player/data/player_lyrics_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cache key uses video and page, without cid', () {
    final PlayableItem withCid = _item(cid: 10, page: null);
    final PlayableItem withoutCid = _item(cid: null, page: 1);

    expect(
      PlayerLyricsCacheRepository.buildCacheKeyForItem(withCid),
      'lyrics:bvid:BV1:page:1',
    );
    expect(
      PlayerLyricsCacheRepository.buildCacheKeyForItem(withCid),
      PlayerLyricsCacheRepository.buildCacheKeyForItem(withoutCid),
    );
  });

  test('cache key keeps different pages separate', () {
    expect(
      PlayerLyricsCacheRepository.buildCacheKeyForItem(_item(cid: 10, page: 1)),
      isNot(
        PlayerLyricsCacheRepository.buildCacheKeyForItem(
          _item(cid: 20, page: 2),
        ),
      ),
    );
  });
}

PlayableItem _item({required int? cid, required int? page}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: 'title',
    author: 'author',
    coverUrl: '',
    cid: cid,
    page: page,
  );
}
