bool allowsMetingLyrics({
  required bool singlePart,
  required bool hasSubtitleTracks,
  required bool manualMatch,
}) {
  if (!singlePart) {
    return true;
  }
  return hasSubtitleTracks || manualMatch;
}

const List<String> _instrumentalMarkers = <String>[
  '纯音乐',
  '纯音',
  '轻音乐',
  '白噪音',
  '无人声',
];

bool looksLikeInstrumental({String? title, String? description}) {
  final String text = '${title ?? ''} ${description ?? ''}';
  if (text.trim().isEmpty) {
    return false;
  }
  for (final String marker in _instrumentalMarkers) {
    if (text.contains(marker)) {
      return true;
    }
  }
  return false;
}
