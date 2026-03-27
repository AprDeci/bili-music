import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_entry.freezed.dart';

@freezed
abstract class FavoriteEntry with _$FavoriteEntry {
  const FavoriteEntry._();

  const factory FavoriteEntry({
    required String itemId,
    required int aid,
    required String bvid,
    required String title,
    required String author,
    required String coverUrl,
    String? durationText,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FavoriteEntry;

  factory FavoriteEntry.fromPlayableItem(PlayableItem item, {DateTime? now}) {
    final DateTime timestamp = now ?? DateTime.now();
    return FavoriteEntry(
      itemId: item.stableId,
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      author: item.author,
      coverUrl: item.coverUrl,
      durationText: item.durationText,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: author,
      coverUrl: coverUrl,
      durationText: durationText,
    );
  }
}
