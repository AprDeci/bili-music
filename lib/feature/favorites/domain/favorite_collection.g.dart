// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteCollection _$FavoriteCollectionFromJson(Map<String, dynamic> json) =>
    _FavoriteCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      source:
          $enumDecodeNullable(
            _$FavoriteCollectionSourceEnumMap,
            json['source'],
          ) ??
          FavoriteCollectionSource.local,
      kind:
          $enumDecodeNullable(_$CollectionKindEnumMap, json['kind']) ??
          CollectionKind.music,
      isSystem: json['isSystem'] as bool? ?? false,
      remoteId: json['remoteId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      isManagedByApp: json['isManagedByApp'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FavoriteCollectionToJson(_FavoriteCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'source': _$FavoriteCollectionSourceEnumMap[instance.source]!,
      'kind': _$CollectionKindEnumMap[instance.kind]!,
      'isSystem': instance.isSystem,
      'remoteId': instance.remoteId,
      'coverUrl': instance.coverUrl,
      'itemCount': instance.itemCount,
      'isManagedByApp': instance.isManagedByApp,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$FavoriteCollectionSourceEnumMap = {
  FavoriteCollectionSource.local: 'local',
  FavoriteCollectionSource.remote: 'remote',
};

const _$CollectionKindEnumMap = {
  CollectionKind.music: 'music',
  CollectionKind.spoken: 'spoken',
};
