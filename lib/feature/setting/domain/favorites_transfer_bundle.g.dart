// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_transfer_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoritesTransferBundle _$FavoritesTransferBundleFromJson(
  Map<String, dynamic> json,
) => _FavoritesTransferBundle(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  exportedAt: DateTime.parse(json['exportedAt'] as String),
  collections:
      (json['collections'] as List<dynamic>?)
          ?.map((e) => FavoriteCollection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FavoriteCollection>[],
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => FavoriteEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FavoriteEntry>[],
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => FavoriteMembership.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FavoriteMembership>[],
);

Map<String, dynamic> _$FavoritesTransferBundleToJson(
  _FavoritesTransferBundle instance,
) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'exportedAt': instance.exportedAt.toIso8601String(),
  'collections': instance.collections,
  'entries': instance.entries,
  'memberships': instance.memberships,
};
