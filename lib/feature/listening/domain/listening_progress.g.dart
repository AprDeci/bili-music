// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListeningProgress _$ListeningProgressFromJson(Map<String, dynamic> json) =>
    _ListeningProgress(
      accountId: json['accountId'] as String,
      aid: (json['aid'] as num).toInt(),
      bvid: json['bvid'] as String,
      cid: (json['cid'] as num).toInt(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      positionMs: (json['positionMs'] as num?)?.toInt() ?? 0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      pendingSync: json['pendingSync'] as bool? ?? false,
      collectionId: json['collectionId'] as String?,
    );

Map<String, dynamic> _$ListeningProgressToJson(_ListeningProgress instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'aid': instance.aid,
      'bvid': instance.bvid,
      'cid': instance.cid,
      'page': instance.page,
      'positionMs': instance.positionMs,
      'durationMs': instance.durationMs,
      'updatedAtMs': instance.updatedAtMs,
      'completed': instance.completed,
      'pendingSync': instance.pendingSync,
      'collectionId': instance.collectionId,
    };
