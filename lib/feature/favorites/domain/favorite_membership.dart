import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_membership.freezed.dart';
part 'favorite_membership.g.dart';

@freezed
abstract class FavoriteMembership with _$FavoriteMembership {
  const FavoriteMembership._();

  const factory FavoriteMembership({
    required String id,
    required String collectionId,
    required String itemId,
    required DateTime addedAt,
  }) = _FavoriteMembership;

  factory FavoriteMembership.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMembershipFromJson(json);

  factory FavoriteMembership.create({
    required String collectionId,
    required String itemId,
    DateTime? addedAt,
  }) {
    return FavoriteMembership(
      id: membershipId(collectionId: collectionId, itemId: itemId),
      collectionId: collectionId,
      itemId: itemId,
      addedAt: addedAt ?? DateTime.now(),
    );
  }

  static String membershipId({
    required String collectionId,
    required String itemId,
  }) {
    return '$collectionId::$itemId';
  }
}
