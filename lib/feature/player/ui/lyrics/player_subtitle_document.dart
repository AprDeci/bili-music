import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:flutter_lyric/flutter_lyric.dart';

LyricDocument buildSubtitleDocument(List<BiliSubtitleLine> subtitles) {
  final List<LyricLine> lines = [];
  for (final BiliSubtitleLine subtitle in subtitles) {
    lines.add(
      LyricLine(
        start: Duration(milliseconds: subtitle.startMs),
        end: Duration(milliseconds: subtitle.endMs),
        text: subtitle.text,
      ),
    );
  }
  return LyricDocument(lines: lines);
}
