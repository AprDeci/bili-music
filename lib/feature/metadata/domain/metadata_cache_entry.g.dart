// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_cache_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MetadataCacheEntry _$MetadataCacheEntryFromJson(Map<String, dynamic> json) =>
    _MetadataCacheEntry(
      stableId: json['stableId'] as String,
      artist: json['artist'] as String?,
      title: json['title'] as String?,
      lyrics: json['lyrics'] as String?,
      metaLyrics: json['metaLyrics'] == null
          ? null
          : MetaLyrics.fromJson(json['metaLyrics'] as Map<String, dynamic>),
      albumArtUrl: json['albumArtUrl'] as String?,
      lyricOffsetMs: (json['lyricOffsetMs'] as num?)?.toInt() ?? 0,
      updatedAtEpochMs: (json['updatedAtEpochMs'] as num).toInt(),
    );

Map<String, dynamic> _$MetadataCacheEntryToJson(_MetadataCacheEntry instance) =>
    <String, dynamic>{
      'stableId': instance.stableId,
      'artist': instance.artist,
      'title': instance.title,
      'lyrics': instance.lyrics,
      'metaLyrics': instance.metaLyrics,
      'albumArtUrl': instance.albumArtUrl,
      'lyricOffsetMs': instance.lyricOffsetMs,
      'updatedAtEpochMs': instance.updatedAtEpochMs,
    };
