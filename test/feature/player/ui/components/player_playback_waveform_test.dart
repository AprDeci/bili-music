import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waveform starts, pauses, resumes and disposes its animation', (
    WidgetTester tester,
  ) async {
    Future<void> showWaveform(bool isPlaying) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(child: PlayerPlaybackWaveform(isPlaying: isPlaying)),
        ),
      );
    }

    await showWaveform(true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.binding.transientCallbackCount, 1);
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(20, 18));

    await showWaveform(false);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);

    await showWaveform(true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.binding.transientCallbackCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('waveform respects reduced motion', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: PlayerPlaybackWaveform(isPlaying: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
