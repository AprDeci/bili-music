class PlayerLyricsCacheEntry {
  const PlayerLyricsCacheEntry({
    required this.stableId,
    required this.rawLyrics,
    required this.lyricOffsetMs,
    required this.updatedAtEpochMs,
  });

  final String stableId;
  final String? rawLyrics;
  final int lyricOffsetMs;
  final int updatedAtEpochMs;

  factory PlayerLyricsCacheEntry.fromJson(Map<String, dynamic> json) {
    final Object? stableId = json['stableId'];
    if (stableId is! String || stableId.trim().isEmpty) {
      throw const FormatException('Invalid lyrics cache stableId.');
    }

    return PlayerLyricsCacheEntry(
      stableId: stableId,
      rawLyrics: json['rawLyrics'] as String?,
      lyricOffsetMs: (json['lyricOffsetMs'] as num?)?.toInt() ?? 0,
      updatedAtEpochMs: (json['updatedAtEpochMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stableId': stableId,
      'rawLyrics': rawLyrics,
      'lyricOffsetMs': lyricOffsetMs,
      'updatedAtEpochMs': updatedAtEpochMs,
    };
  }
}
