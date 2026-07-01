import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_up.freezed.dart';

@freezed
abstract class FavoriteUp with _$FavoriteUp {
  const FavoriteUp._();

  const factory FavoriteUp({
    required int mid,
    required String name,
    required String avatarUrl,
    int? officialType,
    required int favoritedAtEpochMs,
    required int updatedAtEpochMs,
  }) = _FavoriteUp;

  factory FavoriteUp.fromProfile(
    UpProfile profile, {
    FavoriteUp? previous,
    int? nowEpochMs,
  }) {
    final int now = nowEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    return FavoriteUp(
      mid: profile.mid,
      name: profile.name,
      avatarUrl: profile.avatarUrl,
      officialType: profile.officialType,
      favoritedAtEpochMs: previous?.favoritedAtEpochMs ?? now,
      updatedAtEpochMs: now,
    );
  }
}
