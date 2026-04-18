// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteCollection _$FavoriteCollectionFromJson(Map<String, dynamic> json) =>
    _FavoriteCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      isSystem: json['isSystem'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FavoriteCollectionToJson(_FavoriteCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isSystem': instance.isSystem,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
