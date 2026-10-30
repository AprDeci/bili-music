import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

PlayableItem favoriteCollectionPlayableItem(
  FavoriteEntry entry,
  FavoriteCollection collection,
) {
  return entry.toPlayableItem().copyWith(
    kind: collection.kind,
    collectionId: collection.id,
  );
}
