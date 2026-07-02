// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_blacklist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerBlacklistEntry _$PlayerBlacklistEntryFromJson(
  Map<String, dynamic> json,
) => _PlayerBlacklistEntry(
  stableId: json['stableId'] as String,
  aid: (json['aid'] as num).toInt(),
  bvid: json['bvid'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  coverUrl: json['coverUrl'] as String,
  ownerMid: (json['ownerMid'] as num?)?.toInt(),
  cid: (json['cid'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  pageTitle: json['pageTitle'] as String?,
  addedAtEpochMs: (json['addedAtEpochMs'] as num).toInt(),
);

Map<String, dynamic> _$PlayerBlacklistEntryToJson(
  _PlayerBlacklistEntry instance,
) => <String, dynamic>{
  'stableId': instance.stableId,
  'aid': instance.aid,
  'bvid': instance.bvid,
  'title': instance.title,
  'author': instance.author,
  'coverUrl': instance.coverUrl,
  'ownerMid': instance.ownerMid,
  'cid': instance.cid,
  'page': instance.page,
  'pageTitle': instance.pageTitle,
  'addedAtEpochMs': instance.addedAtEpochMs,
};
