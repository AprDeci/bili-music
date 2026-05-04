import 'dart:math' as math;

import 'package:flutter/material.dart';

class PingPongMarqueePlus extends StatefulWidget {
  const PingPongMarqueePlus({
    super.key,
    required this.text,
    this.speed = 40,
    this.pauseDuration = const Duration(seconds: 2),
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final double speed;
  final Duration pauseDuration;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<PingPongMarqueePlus> createState() => _PingPongMarqueePlusState();
}

class _PingPongMarqueePlusState extends State<PingPongMarqueePlus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _generation = 0;
  bool _isForward = true;
  double _maxOffset = 0;
  double? _lastWidth;
  TextStyle? _lastStyle;
  String? _lastText;
  TextDirection? _lastTextDirection;
  TextScaler? _lastTextScaler;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
  }

  @override
  void didUpdateWidget(covariant PingPongMarqueePlus oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed ||
        oldWidget.pauseDuration != widget.pauseDuration ||
        oldWidget.style != widget.style) {
      _resetAnimation();
    }
  }

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _generation++;
    _isForward = true;
    _controller.stop();
    _controller.value = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startLoop();
      }
    });
  }

  void _updateMetrics({
    required double width,
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final bool metricsChanged =
        _lastWidth != width ||
        _lastStyle != style ||
        _lastText != widget.text ||
        _lastTextDirection != textDirection ||
        _lastTextScaler != textScaler;

    if (!metricsChanged) {
      return;
    }

    _lastWidth = width;
    _lastStyle = style;
    _lastText = widget.text;
    _lastTextDirection = textDirection;
    _lastTextScaler = textScaler;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();

    final double nextMaxOffset = math.max(0, textPainter.width - width);
    if (nextMaxOffset == _maxOffset) {
      return;
    }

    _maxOffset = nextMaxOffset;
    _resetAnimationAfterFrame();
  }

  void _resetAnimationAfterFrame() {
    _generation++;
    _isForward = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _controller.stop();
      _controller.value = 0;
      _startLoop();
    });
  }

  void _startLoop() {
    final int generation = _generation;

    if (_maxOffset <= 0 || widget.speed <= 0) {
      return;
    }

    _runLoop(generation);
  }

  Future<void> _runLoop(int generation) async {
    while (mounted && generation == _generation) {
      await Future<void>.delayed(widget.pauseDuration);

      if (!mounted || generation != _generation) {
        return;
      }

      if (_maxOffset <= 0 || widget.speed <= 0) {
        return;
      }

      final double target = _isForward ? -_maxOffset : 0;
      final double distance = (target - _controller.value).abs();
      if (distance <= 0) {
        _isForward = !_isForward;
        continue;
      }

      await _controller.animateTo(
        target,
        duration: Duration(
          milliseconds: (distance / widget.speed * 1000).round(),
        ),
        curve: Curves.linear,
      );

      if (!mounted || generation != _generation) {
        return;
      }

      _isForward = !_isForward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        widget.style ??
        DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 16, color: Colors.white);
    final TextDirection textDirection = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        _updateMetrics(
          width: width,
          style: effectiveStyle,
          textDirection: textDirection,
          textScaler: textScaler,
        );

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            child: SizedBox(
              width: width,
              child: Text(
                widget.text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: effectiveStyle,
                textAlign: widget.textAlign,
                textScaler: textScaler,
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return Transform.translate(
                offset: Offset(_maxOffset > 0 ? _controller.value : 0, 0),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
