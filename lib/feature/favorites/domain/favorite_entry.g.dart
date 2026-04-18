// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteEntry _$FavoriteEntryFromJson(Map<String, dynamic> json) =>
    _FavoriteEntry(
      itemId: json['itemId'] as String,
      aid: (json['aid'] as num).toInt(),
      bvid: json['bvid'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String,
      cid: (json['cid'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      pageTitle: json['pageTitle'] as String?,
      durationText: json['durationText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FavoriteEntryToJson(_FavoriteEntry instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'aid': instance.aid,
      'bvid': instance.bvid,
      'title': instance.title,
      'author': instance.author,
      'coverUrl': instance.coverUrl,
      'cid': instance.cid,
      'page': instance.page,
      'pageTitle': instance.pageTitle,
      'durationText': instance.durationText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
