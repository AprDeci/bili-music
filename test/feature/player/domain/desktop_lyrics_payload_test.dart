import 'package:bilimusic/feature/player/domain/desktop_lyrics_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DesktopLyricsPayload', () {
    test('round-trips json fields used by the desktop lyrics window', () {
      const DesktopLyricsPayload payload = DesktopLyricsPayload(
        title: 'Song title',
        currentLyric: 'Current line',
        nextLyric: 'Next line',
        isPlaying: true,
        isFavorite: true,
        canGoPrevious: true,
        canGoNext: false,
        hasItem: true,
        opacity: 0.7,
        alwaysOnTop: false,
      );

      final DesktopLyricsPayload decoded = DesktopLyricsPayload.fromJson(
        payload.toJson(),
      );

      expect(decoded.title, payload.title);
      expect(decoded.currentLyric, payload.currentLyric);
      expect(decoded.nextLyric, payload.nextLyric);
      expect(decoded.isPlaying, payload.isPlaying);
      expect(decoded.isFavorite, payload.isFavorite);
      expect(decoded.canGoPrevious, payload.canGoPrevious);
      expect(decoded.canGoNext, payload.canGoNext);
      expect(decoded.hasItem, payload.hasItem);
      expect(decoded.opacity, payload.opacity);
      expect(decoded.alwaysOnTop, payload.alwaysOnTop);
    });

    test('uses fallbacks for blank string values', () {
      final DesktopLyricsPayload payload = DesktopLyricsPayload.fromJson(
        <String, dynamic>{'title': '  ', 'currentLyric': '', 'nextLyric': '  '},
      );

      expect(payload.title, '桌面歌词');
      expect(payload.currentLyric, '暂无播放内容');
      expect(payload.nextLyric, '');
    });
  });

  group('DesktopLyricsCommand', () {
    test('maps commands to IPC method names', () {
      for (final DesktopLyricsCommand command in DesktopLyricsCommand.values) {
        expect(desktopLyricsCommandFromMethodName(command.methodName), command);
      }
      expect(desktopLyricsCommandFromMethodName('unknown'), isNull);
    });
  });
}
