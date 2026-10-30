import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
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
