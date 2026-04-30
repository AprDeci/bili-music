// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transfer_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTransferBundle _$AppTransferBundleFromJson(Map<String, dynamic> json) =>
    _AppTransferBundle(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 2,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      favorites: FavoritesTransferBundle.fromJson(
        json['favorites'] as Map<String, dynamic>,
      ),
      settings:
          (json['settings'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$AppTransferBundleToJson(_AppTransferBundle instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'exportedAt': instance.exportedAt.toIso8601String(),
      'favorites': instance.favorites,
      'settings': instance.settings,
    };
