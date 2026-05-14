import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata.freezed.dart';

@freezed
abstract class Metadata with _$Metadata {
  const factory Metadata({
    required String stableId,
    String? artist,
    String? title,
    String? lyrics,
    String? albumArtUrl,
    @Default(0) int lyricOffsetMs,
    DateTime? updatedAt,
  }) = _Metadata;

  const Metadata._();

  bool get hasLyrics => lyrics != null && lyrics!.trim().isNotEmpty;
}
