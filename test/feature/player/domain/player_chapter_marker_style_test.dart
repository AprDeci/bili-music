import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromStorage resolves known style names', () {
    expect(
      PlayerChapterMarkerStyle.fromStorage('dot'),
      PlayerChapterMarkerStyle.dot,
    );
    expect(
      PlayerChapterMarkerStyle.fromStorage('line'),
      PlayerChapterMarkerStyle.line,
    );
  });

  test('fromStorage falls back to line for unknown or empty values', () {
    expect(
      PlayerChapterMarkerStyle.fromStorage(null),
      PlayerChapterMarkerStyle.line,
    );
    expect(
      PlayerChapterMarkerStyle.fromStorage(''),
      PlayerChapterMarkerStyle.line,
    );
    expect(
      PlayerChapterMarkerStyle.fromStorage('future-style'),
      PlayerChapterMarkerStyle.line,
    );
  });

  test('every style exposes a label and description', () {
    for (final PlayerChapterMarkerStyle style
        in PlayerChapterMarkerStyle.values) {
      expect(style.label, isNotEmpty);
      expect(style.description, isNotEmpty);
    }
  });
}
