import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

String buildFavoriteEntryTitle(FavoriteEntry item) {
  return item.toPlayableItem().displayTitle;
}

String buildFavoriteEntrySubtitle(FavoriteEntry item) {
  final PlayableItem playableItem = item.toPlayableItem();
  final List<String> segments = <String>[playableItem.displaySubtitle];
  final String durationText = item.durationText?.trim() ?? '';

  if (durationText.isNotEmpty) {
    segments.add(durationText);
  }

  return segments.join(' · ');
}
