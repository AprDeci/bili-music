import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class CommonPieChart extends StatefulWidget {
  const CommonPieChart({super.key, required this.data});

  final CommonPieChartData data;

  @override
  State<CommonPieChart> createState() => _CommonPieChartState();
}

class _CommonPieChartState extends State<CommonPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double> _fromValues;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.data.animationDuration,
      value: widget.data.animate ? 0.0 : 1.0,
    );
    _fromValues = List<double>.filled(widget.data.sections.length, 0.0);

    if (widget.data.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CommonPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.animationDuration != widget.data.animationDuration) {
      _controller.duration = widget.data.animationDuration;
    }

    if (_didSectionValuesChange(
      oldWidget.data.sections,
      widget.data.sections,
    )) {
      _fromValues = _resolvedAnimatedValues();
      if (widget.data.animate) {
        _controller
          ..value = 0.0
          ..forward();
      } else {
        _controller.value = 1.0;
      }
    }
  }

  bool _didSectionValuesChange(
    List<CommonPieChartSectionData> oldSections,
    List<CommonPieChartSectionData> newSections,
  ) {
    if (oldSections.length != newSections.length) {
      return true;
    }

    for (int index = 0; index < oldSections.length; index++) {
      final CommonPieChartSectionData oldSection = oldSections[index];
      final CommonPieChartSectionData newSection = newSections[index];
      if (oldSection.value != newSection.value ||
          oldSection.color != newSection.color ||
          oldSection.radius != newSection.radius ||
          oldSection.texture != newSection.texture ||
          oldSection.label != newSection.label) {
        return true;
      }
    }

    return false;
  }

  List<double> _resolvedAnimatedValues() {
    final double curvedValue = widget.data.animationCurve.transform(
      _controller.value,
    );
    final int maxLength = math.max(
      _fromValues.length,
      widget.data.sections.length,
    );

    return List<double>.generate(maxLength, (int index) {
      final double from = index < _fromValues.length ? _fromValues[index] : 0.0;
      final double to = index < widget.data.sections.length
          ? widget.data.sections[index].value
          : 0.0;
      return lerpDouble(from, to, curvedValue) ?? to;
    }, growable: false);
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    final ValueChanged<int>? onSectionTap = widget.data.onSectionTap;
    if (onSectionTap == null) {
      return;
    }

    final List<double> animatedValues = _resolvedAnimatedValues();
    final int? sectionIndex = _locateSectionIndex(
      localPosition: details.localPosition,
      size: size,
      data: widget.data,
      animatedValues: animatedValues,
    );
    if (sectionIndex != null) {
      onSectionTap(sectionIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color centerColor =
        widget.data.centerSpaceColor ?? theme.scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 200;
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : width;
        final Size size = Size(width, height);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (TapUpDetails details) => _handleTapUp(details, size),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final List<double> animatedValues = _resolvedAnimatedValues();

              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _CommonPieChartPainter(
                        data: widget.data,
                        animatedValues: animatedValues,
                        centerColor: centerColor,
                      ),
                    ),
                  ),
                  if (widget.data.center != null)
                    IgnorePointer(
                      child: SizedBox(
                        width: widget.data.centerSpaceRadius * 2,
                        height: widget.data.centerSpaceRadius * 2,
                        child: Center(child: widget.data.center),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class CommonPieChartData {
  const CommonPieChartData({
    required this.sections,
    this.center,
    this.centerSpaceRadius = 48,
    this.centerSpaceColor,
    this.startAngleDegrees = -90,
    this.sectionGapDegrees = 2,
    this.chartPadding = 12,
    this.selectedSectionIndex,
    this.selectedSectionExpand = 8,
    this.showLabels = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.animate = true,
    this.onSectionTap,
  });

  final List<CommonPieChartSectionData> sections;
  final Widget? center;
  final double centerSpaceRadius;
  final Color? centerSpaceColor;
  final double startAngleDegrees;
  final double sectionGapDegrees;
  final double chartPadding;
  final int? selectedSectionIndex;
  final double selectedSectionExpand;
  final bool showLabels;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool animate;
  final ValueChanged<int>? onSectionTap;
}

class CommonPieChartSectionData {
  const CommonPieChartSectionData({
    required this.value,
    required this.color,
    this.label,
    this.labelStyle,
    this.labelPosition = 0.62,
    this.radius,
    this.texture,
  });

  final double value;
  final Color color;
  final String? label;
  final TextStyle? labelStyle;
  final double labelPosition;
  final double? radius;
  final CommonPieChartTexture? texture;
}

class CommonPieChartTexture {
  const CommonPieChartTexture({
    required this.icon,
    this.color = Colors.white,
    this.opacity = 0.12,
    this.size = 13,
    this.spacing = 26,
    this.rotationJitter = 0.35,
    this.offsetJitter = 6,
    this.stagger = true,
  });

  final IconData icon;
  final Color color;
  final double opacity;
  final double size;
  final double spacing;
  final double rotationJitter;
  final double offsetJitter;
  final bool stagger;
}

class _CommonPieChartPainter extends CustomPainter {
  const _CommonPieChartPainter({
    required this.data,
    required this.animatedValues,
    required this.centerColor,
  });

  final CommonPieChartData data;
  final List<double> animatedValues;
  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxOuterRadius =
        size.shortestSide / 2 - data.chartPadding - data.selectedSectionExpand;
    final double innerRadius = math.min(data.centerSpaceRadius, maxOuterRadius);
    final double total = animatedValues.fold<double>(0.0, (
      double sum,
      double value,
    ) {
      return sum + math.max(0.0, value);
    });

    if (total <= 0 || maxOuterRadius <= innerRadius) {
      _paintCenter(canvas, center, innerRadius);
      return;
    }

    final double gapRadians = data.sectionGapDegrees * math.pi / 180;
    final double startRadians = data.startAngleDegrees * math.pi / 180;
    double currentAngle = startRadians;

    for (int index = 0; index < data.sections.length; index++) {
      final CommonPieChartSectionData section = data.sections[index];
      final double value = index < animatedValues.length
          ? animatedValues[index]
          : 0.0;
      if (value <= 0) {
        continue;
      }

      final double rawSweep = value / total * math.pi * 2;
      final double sweep = math.max(0.0, rawSweep - gapRadians);
      final bool isSelected = data.selectedSectionIndex == index;
      final double outerRadius = math.max(
        innerRadius + 8,
        math.min(section.radius ?? maxOuterRadius, maxOuterRadius) +
            (isSelected ? data.selectedSectionExpand : 0),
      );

      if (sweep <= 0) {
        currentAngle += rawSweep;
        continue;
      }

      final double sectionStart = currentAngle + gapRadians / 2;
      final Path sectionPath = _buildSectionPath(
        center: center,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        startAngle: sectionStart,
        sweepAngle: sweep,
      );

      final Paint fillPaint = Paint()..color = section.color;
      canvas.drawPath(sectionPath, fillPaint);

      if (section.texture case final CommonPieChartTexture texture) {
        _paintTexture(canvas, size, sectionPath, texture, index);
      }

      if (data.showLabels && (section.label?.isNotEmpty ?? false)) {
        _paintLabel(
          canvas,
          center,
          innerRadius,
          outerRadius,
          sectionStart,
          sweep,
          section,
        );
      }

      currentAngle += rawSweep;
    }

    _paintCenter(canvas, center, innerRadius);
  }

  void _paintCenter(Canvas canvas, Offset center, double innerRadius) {
    final Paint centerPaint = Paint()..color = centerColor;
    canvas.drawCircle(center, innerRadius, centerPaint);
  }

  Path _buildSectionPath({
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double startAngle,
    required double sweepAngle,
  }) {
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final Path path = Path()
      ..arcTo(outerRect, startAngle, sweepAngle, false)
      ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
      ..close();
    return path;
  }

  void _paintTexture(
    Canvas canvas,
    Size size,
    Path sectionPath,
    CommonPieChartTexture texture,
    int sectionIndex,
  ) {
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(texture.icon.codePoint),
        style: TextStyle(
          fontSize: texture.size,
          fontFamily: texture.icon.fontFamily,
          package: texture.icon.fontPackage,
          color: texture.color.withValues(alpha: texture.opacity),
        ),
      ),
    )..layout();

    final Rect bounds = sectionPath.getBounds();
    final double spacing = math.max(texture.spacing, texture.size + 4);
    final int rows = ((bounds.height / spacing).ceil()) + 2;
    final int columns = ((bounds.width / spacing).ceil()) + 2;

    canvas.save();
    canvas.clipPath(sectionPath);

    for (int row = -1; row < rows; row++) {
      for (int column = -1; column < columns; column++) {
        final double baseX = bounds.left + (column * spacing);
        final double baseY = bounds.top + (row * spacing);
        final double staggerOffset = texture.stagger && row.isOdd
            ? spacing / 2
            : 0;
        final double jitterX =
            (_hash(sectionIndex, row, column, 1) - 0.5) *
            2 *
            texture.offsetJitter;
        final double jitterY =
            (_hash(sectionIndex, row, column, 2) - 0.5) *
            2 *
            texture.offsetJitter;
        final double rotation =
            (_hash(sectionIndex, row, column, 3) - 0.5) *
            2 *
            texture.rotationJitter;
        final Offset position = Offset(
          baseX + staggerOffset + jitterX,
          baseY + jitterY,
        );

        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(rotation);
        painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    double startAngle,
    double sweep,
    CommonPieChartSectionData section,
  ) {
    final double angle = startAngle + sweep / 2;
    final double radius =
        innerRadius + (outerRadius - innerRadius) * section.labelPosition;
    final Offset labelCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      text: TextSpan(
        text: section.label,
        style:
            section.labelStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
      ),
    )..layout();

    painter.paint(
      canvas,
      Offset(
        labelCenter.dx - painter.width / 2,
        labelCenter.dy - painter.height / 2,
      ),
    );
  }

  double _hash(int a, int b, int c, int d) {
    final double value =
        math.sin(a * 12.9898 + b * 78.233 + c * 37.719 + d * 19.313) *
        43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _CommonPieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.centerColor != centerColor ||
        !_listEquals(oldDelegate.animatedValues, animatedValues);
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}

int? _locateSectionIndex({
  required Offset localPosition,
  required Size size,
  required CommonPieChartData data,
  required List<double> animatedValues,
}) {
  final Offset center = size.center(Offset.zero);
  final Offset vector = localPosition - center;
  final double distance = vector.distance;
  final double maxOuterRadius =
      size.shortestSide / 2 - data.chartPadding - data.selectedSectionExpand;
  final double innerRadius = math.min(data.centerSpaceRadius, maxOuterRadius);

  if (distance < innerRadius ||
      distance > maxOuterRadius + data.selectedSectionExpand) {
    return null;
  }

  final double total = animatedValues.fold<double>(0.0, (
    double sum,
    double value,
  ) {
    return sum + math.max(0.0, value);
  });
  if (total <= 0) {
    return null;
  }

  final double gapRadians = data.sectionGapDegrees * math.pi / 180;
  final double normalizedAngle = _normalizeAngle(
    math.atan2(vector.dy, vector.dx),
  );
  double currentAngle = _normalizeAngle(data.startAngleDegrees * math.pi / 180);

  for (int index = 0; index < data.sections.length; index++) {
    final double value = index < animatedValues.length
        ? animatedValues[index]
        : 0.0;
    if (value <= 0) {
      continue;
    }

    final double rawSweep = value / total * math.pi * 2;
    final double start = _normalizeAngle(currentAngle + gapRadians / 2);
    final double sweep = math.max(0.0, rawSweep - gapRadians);

    if (_isAngleWithin(normalizedAngle, start, sweep)) {
      return index;
    }

    currentAngle = _normalizeAngle(currentAngle + rawSweep);
  }

  return null;
}

bool _isAngleWithin(double angle, double start, double sweep) {
  final double end = _normalizeAngle(start + sweep);
  if (sweep >= math.pi * 2) {
    return true;
  }

  if (start <= end) {
    return angle >= start && angle <= end;
  }

  return angle >= start || angle <= end;
}

double _normalizeAngle(double angle) {
  final double turn = math.pi * 2;
  double normalized = angle % turn;
  if (normalized < 0) {
    normalized += turn;
  }
  return normalized;
}
