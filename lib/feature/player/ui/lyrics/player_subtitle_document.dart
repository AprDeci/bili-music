import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:flutter_lyric/flutter_lyric.dart';

LyricDocument buildSubtitleDocument(List<BiliSubtitleLine> subtitles) {
  final List<LyricLine> lines = [];
  for (int index = 0; index < subtitles.length; index++) {
    final BiliSubtitleLine subtitle = subtitles[index];
    lines.add(
      LyricLine(
        start: Duration(milliseconds: subtitle.startMs),
        end: Duration(milliseconds: subtitle.endMs),
        text: subtitle.text,
      ),
    );
    final int? nextStart = index + 1 < subtitles.length
        ? subtitles[index + 1].startMs
        : null;
    if (nextStart == null || subtitle.endMs < nextStart) {
      lines.add(
        LyricLine(
          start: Duration(milliseconds: subtitle.endMs),
          text: '',
        ),
      );
    }
  }
  return LyricDocument(lines: lines);
}
