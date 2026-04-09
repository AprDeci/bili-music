// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteMembership _$FavoriteMembershipFromJson(Map<String, dynamic> json) =>
    _FavoriteMembership(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      itemId: json['itemId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$FavoriteMembershipToJson(_FavoriteMembership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'itemId': instance.itemId,
      'addedAt': instance.addedAt.toIso8601String(),
    };
