import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_transfer_bundle.freezed.dart';
part 'favorites_transfer_bundle.g.dart';

@freezed
abstract class FavoritesTransferBundle with _$FavoritesTransferBundle {
  const FavoritesTransferBundle._();

  const factory FavoritesTransferBundle({
    @Default(1) int schemaVersion,
    required DateTime exportedAt,
    @Default(<FavoriteCollection>[]) List<FavoriteCollection> collections,
    @Default(<FavoriteEntry>[]) List<FavoriteEntry> entries,
    @Default(<FavoriteMembership>[]) List<FavoriteMembership> memberships,
  }) = _FavoritesTransferBundle;

  factory FavoritesTransferBundle.fromJson(Map<String, dynamic> json) =>
      _$FavoritesTransferBundleFromJson(json);
}
