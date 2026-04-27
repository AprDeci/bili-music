import 'dart:math' as math;

import 'package:flutter/material.dart';

class CommonAttachPanel extends StatelessWidget {
  const CommonAttachPanel({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.bodyHeight,
    this.padding,
    this.arrowSize = 18,
    this.borderRadius = 8,
  });

  final Widget child;
  final double width;
  final double height;
  final double? bodyHeight;
  final EdgeInsetsGeometry? padding;
  final double arrowSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double resolvedBodyHeight = bodyHeight ?? height - arrowSize + 6;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              bottom: 8,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: arrowSize,
                  height: arrowSize,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: width,
                height: resolvedBodyHeight,
                padding: padding,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
