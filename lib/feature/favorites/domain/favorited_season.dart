import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorited_season.freezed.dart';

@freezed
abstract class FavoritedSeason with _$FavoritedSeason {
  const factory FavoritedSeason({
    required int seasonId,
    required int mid,
    required String title,
    required String coverUrl,
    String? description,
    required int total,
    required int favoritedAtEpochMs,
    required int updatedAtEpochMs,
    required int lastSyncedAtEpochMs,
  }) = _FavoritedSeason;

  factory FavoritedSeason.fromCollection(
    UpCollection collection, {
    FavoritedSeason? previous,
    int? nowEpochMs,
  }) {
    final int now = nowEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    return FavoritedSeason(
      seasonId: collection.seasonId,
      mid: collection.mid,
      title: collection.title,
      coverUrl: collection.coverUrl,
      description: collection.description,
      total: collection.total,
      favoritedAtEpochMs: previous?.favoritedAtEpochMs ?? now,
      updatedAtEpochMs: collection.updatedAt?.millisecondsSinceEpoch ?? now,
      lastSyncedAtEpochMs: now,
    );
  }
}
