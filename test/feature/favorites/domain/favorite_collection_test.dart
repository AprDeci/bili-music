import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy collection JSON defaults to music', () {
    final FavoriteCollection collection =
        FavoriteCollection.fromJson(<String, dynamic>{
          'id': 'legacy',
          'name': '旧歌单',
          'createdAt': '2026-01-01T00:00:00.000',
          'updatedAt': '2026-01-01T00:00:00.000',
        });
    expect(collection.kind, CollectionKind.music);
    expect(FavoriteCollection.liked().kind, CollectionKind.music);
  });

  test('context belongs to the target collection, not the content', () {
    const PlayableItem source = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      cid: 10,
      page: 2,
      title: 'Title',
      author: 'Author',
      coverUrl: 'Cover',
      kind: CollectionKind.spoken,
      collectionId: 'source',
    );
    final FavoriteEntry entry = FavoriteEntry.fromPlayableItem(source);
    final FavoriteCollection music = FavoriteCollection(
      id: 'music',
      name: 'Music',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final FavoriteCollection spoken = music.copyWith(
      id: 'spoken',
      kind: CollectionKind.spoken,
    );
    expect(music.isSpoken, isFalse);
    expect(spoken.isSpoken, isTrue);
    expect(
      music.contextualize(source),
      source.copyWith(kind: CollectionKind.music, collectionId: music.id),
    );
    final PlayableItem musicItem = entry.toPlayableItem(collection: music);
    final PlayableItem spokenItem = entry.toPlayableItem(collection: spoken);
    expect(musicItem, music.contextualize(source));
    expect(spokenItem, spoken.contextualize(source));
    expect(musicItem.kind, CollectionKind.music);
    expect(spokenItem.kind, CollectionKind.spoken);
    expect(musicItem.collectionId, music.id);
    expect(spokenItem.collectionId, spoken.id);
    expect(musicItem.stableId, source.stableId);
    expect(spokenItem.contentId, source.contentId);
    expect(entry.toPlayableItem().collectionId, isNull);
    expect(entry.toPlayableItem().kind, CollectionKind.music);
  });

  test('spoken collection JSON and copies preserve kind', () {
    final FavoriteCollection collection = FavoriteCollection(
      id: 'spoken',
      name: '听书',
      kind: CollectionKind.spoken,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(collection.toJson()['kind'], 'spoken');
    expect(FavoriteCollection.fromJson(collection.toJson()), collection);
    expect(collection.copyWith(name: '听声').kind, CollectionKind.spoken);
  });
}
