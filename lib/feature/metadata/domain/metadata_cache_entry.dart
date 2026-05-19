import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata_cache_entry.freezed.dart';
part 'metadata_cache_entry.g.dart';

@freezed
abstract class MetadataCacheEntry with _$MetadataCacheEntry {
  const factory MetadataCacheEntry({
    required String stableId,
    String? artist,
    String? title,
    String? lyrics,
    MetaLyrics? metaLyrics,
    String? albumArtUrl,
    @Default(0) int lyricOffsetMs,
    required int updatedAtEpochMs,
  }) = _MetadataCacheEntry;

  const MetadataCacheEntry._();

  factory MetadataCacheEntry.fromJson(Map<String, dynamic> json) =>
      _$MetadataCacheEntryFromJson(json);

  Metadata toMetadata() {
    return Metadata(
      stableId: stableId,
      artist: artist,
      title: title,
      lyrics: lyrics,
      metaLyrics: metaLyrics,
      albumArtUrl: albumArtUrl,
      lyricOffsetMs: lyricOffsetMs,
      updatedAt: updatedAtEpochMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpochMs)
          : null,
    );
  }

  factory MetadataCacheEntry.fromMetadata(Metadata metadata) {
    return MetadataCacheEntry(
      stableId: metadata.stableId,
      artist: metadata.artist,
      title: metadata.title,
      lyrics: metadata.lyrics,
      metaLyrics: metadata.metaLyrics,
      albumArtUrl: metadata.albumArtUrl,
      lyricOffsetMs: metadata.lyricOffsetMs,
      updatedAtEpochMs:
          metadata.updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}
