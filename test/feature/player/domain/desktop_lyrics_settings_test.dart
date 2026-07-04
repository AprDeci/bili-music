import 'package:bilimusic/feature/player/domain/desktop_lyrics_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DesktopLyricsSettings', () {
    test('clampOpacity keeps value inside supported range', () {
      expect(DesktopLyricsSettings.clampOpacity(0.1), 0.2);
      expect(DesktopLyricsSettings.clampOpacity(0.6), 0.6);
      expect(DesktopLyricsSettings.clampOpacity(1.2), 1.0);
    });

    test('copyWith preserves unchanged fields', () {
      const DesktopLyricsSettings settings = DesktopLyricsSettings(
        enabled: false,
        alwaysOnTop: true,
        opacity: 0.86,
      );

      expect(
        settings.copyWith(enabled: true),
        isA<DesktopLyricsSettings>()
            .having(
              (DesktopLyricsSettings value) => value.enabled,
              'enabled',
              true,
            )
            .having(
              (DesktopLyricsSettings value) => value.alwaysOnTop,
              'alwaysOnTop',
              true,
            )
            .having(
              (DesktopLyricsSettings value) => value.opacity,
              'opacity',
              0.86,
            ),
      );
    });
  });
}
