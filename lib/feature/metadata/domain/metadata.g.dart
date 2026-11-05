// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Metadata _$MetadataFromJson(Map<String, dynamic> json) => _Metadata(
  stableId: json['stableId'] as String,
  artist: json['artist'] as String?,
  title: json['title'] as String?,
  lyrics: json['lyrics'] as String?,
  metaLyrics: json['metaLyrics'] == null
      ? null
      : MetaLyrics.fromJson(json['metaLyrics'] as Map<String, dynamic>),
  albumArtUrl: json['albumArtUrl'] as String?,
  lyricBaseOffsetMs: (json['lyricBaseOffsetMs'] as num?)?.toInt() ?? 0,
  lyricOffsetMs: (json['lyricOffsetMs'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MetadataToJson(_Metadata instance) => <String, dynamic>{
  'stableId': instance.stableId,
  'artist': instance.artist,
  'title': instance.title,
  'lyrics': instance.lyrics,
  'metaLyrics': instance.metaLyrics,
  'albumArtUrl': instance.albumArtUrl,
  'lyricBaseOffsetMs': instance.lyricBaseOffsetMs,
  'lyricOffsetMs': instance.lyricOffsetMs,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
