import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlayerPlaybackWaveform extends StatefulWidget {
  const PlayerPlaybackWaveform({super.key, required this.isPlaying});

  final bool isPlaying;

  @override
  State<PlayerPlaybackWaveform> createState() => _PlayerPlaybackWaveformState();
}

class _PlayerPlaybackWaveformState extends State<PlayerPlaybackWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PlayerPlaybackWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.isPlaying && !MediaQuery.disableAnimationsOf(context)) {
      if (!_animation.isAnimating) {
        _animation.repeat();
      }
    } else {
      _animation.stop();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(20, 18),
        painter: _PlaybackWaveformPainter(
          animation: _animation,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _PlaybackWaveformPainter extends CustomPainter {
  _PlaybackWaveformPainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double phase = animation.value * math.pi * 2;
    for (int index = 0; index < 5; index += 1) {
      final double wave = (math.sin(phase + index * 1.7) + 1) / 2;
      final double height = size.height * (0.2 + 0.8 * wave);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            index * size.width / 5,
            (size.height - height) / 2,
            size.width / 8,
            height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlaybackWaveformPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.animation != animation;
  }
}
