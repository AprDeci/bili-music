import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display lyric offset adds the chapter base offset', () {
    expect(resolveDisplayLyricOffsetMs(null), 0);
    expect(resolveDisplayLyricOffsetMs(const Metadata(stableId: 'x')), 0);
    expect(
      resolveDisplayLyricOffsetMs(
        const Metadata(
          stableId: 'x',
          lyricBaseOffsetMs: -120000,
          lyricOffsetMs: 300,
        ),
      ),
      -119700,
    );
  });
}
