import 'dart:math' as math;

import 'package:flutter/material.dart';

class CarUiViewport extends StatelessWidget {
  const CarUiViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final double scale = math.max(
      1,
      math.min(media.size.width / 1280, media.size.height / 720),
    );
    final Size size = media.size / scale;
    return FittedBox(
      child: SizedBox.fromSize(
        size: size,
        child: MediaQuery(
          data: media.copyWith(
            size: size,
            devicePixelRatio: media.devicePixelRatio * scale,
            padding: media.padding / scale,
            viewPadding: media.viewPadding / scale,
            viewInsets: media.viewInsets / scale,
            systemGestureInsets: media.systemGestureInsets / scale,
          ),
          child: child,
        ),
      ),
    );
  }
}
