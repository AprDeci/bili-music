import 'package:bilimusic/feature/player/logic/desktop_lyrics_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves LRC lines with offset and progress boundaries', () {
    const String lyrics = '[00:01.00]one\n[00:03.00]two';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 500),
        offsetMs: 0,
      ),
      isNull,
    );
    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1500),
        offsetMs: 500,
      )?.progress,
      0.5,
    );
    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(seconds: 3),
        offsetMs: 0,
      )?.progress,
      1,
    );
  });

  test('keeps the previous LRC line during empty timestamps', () {
    const String lyrics =
        '[00:01.00]\n'
        '[00:02.00]one\n'
        '[00:03.00]\n'
        '[00:04.00]\n'
        '[00:05.00]two\n'
        '[00:07.00]three';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1500),
        offsetMs: 0,
      ),
      isNull,
    );
    for (final int positionMs in <int>[3000, 4000]) {
      expect(
        resolveDesktopLyricFrame(
          lyrics,
          position: Duration(milliseconds: positionMs),
          offsetMs: 0,
        ),
        isA<DesktopLyricFrame>()
            .having((DesktopLyricFrame frame) => frame.line, 'line', 'one')
            .having((DesktopLyricFrame frame) => frame.progress, 'progress', 1),
      );
    }
    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 5000),
        offsetMs: 0,
      ),
      isA<DesktopLyricFrame>()
          .having((DesktopLyricFrame frame) => frame.line, 'line', 'two')
          .having((DesktopLyricFrame frame) => frame.progress, 'progress', 0),
    );
  });

  test('resolves QRC duration progress boundaries', () {
    const String lyrics = '[1000,2000]line';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1000),
        offsetMs: 0,
      ),
      isA<DesktopLyricFrame>()
          .having((DesktopLyricFrame frame) => frame.line, 'line', 'line')
          .having((DesktopLyricFrame frame) => frame.progress, 'progress', 0),
    );
    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 5000),
        offsetMs: 0,
      ),
      isA<DesktopLyricFrame>()
          .having((DesktopLyricFrame frame) => frame.line, 'line', 'line')
          .having((DesktopLyricFrame frame) => frame.progress, 'progress', 1),
    );
  });

  test('strips KRC word timings after each character', () {
    const String lyrics =
        '[offset,0]\n'
        '[1790,2062,0]那(1790,375,0)一(2165,309,0)年(2474,315,0)';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 2821),
        offsetMs: 0,
      ),
      isA<DesktopLyricFrame>()
          .having((DesktopLyricFrame frame) => frame.line, 'line', '那一年')
          .having((DesktopLyricFrame frame) => frame.progress, 'progress', 0.5),
    );
  });

  test('strips QRC two-value word timings', () {
    const String lyrics =
        '[1790,2062]那(1790,375)一(2165,309)年(2474,315)汪(2789,311)';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1790),
        offsetMs: 0,
      )?.line,
      '那一年汪',
    );
  });

  test('strips YRC word timings before each character', () {
    const String lyrics = '[1790,2062] (1790,375,0)那(2165,309,0)一(2474,315,0)年';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1790),
        offsetMs: 0,
      )?.line,
      '那一年',
    );
  });

  test('applies embedded and display offsets', () {
    const String lyrics = '[offset:200]\n[1000,1000]line';

    expect(
      resolveDesktopLyricFrame(
        lyrics,
        position: const Duration(milliseconds: 1100),
        offsetMs: 100,
      )?.progress,
      0,
    );
    expect(
      resolveDesktopLyricFrame(
        '[offset:-200]\n[1000,1000]line',
        position: const Duration(milliseconds: 700),
        offsetMs: 100,
      )?.progress,
      0,
    );
  });
}
