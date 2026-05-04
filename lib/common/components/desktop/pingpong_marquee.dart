import 'package:flutter/material.dart';

class PingPongMarquee extends StatefulWidget {
  final String text;
  final double speed; // 像素/秒，
  final Duration pauseDuration; // 停顿时间，默认 2 秒
  final TextStyle? style;

  const PingPongMarquee({
    super.key,
    required this.text,
    this.speed = 40,
    this.pauseDuration = const Duration(seconds: 2),
    this.style,
  });

  @override
  State<PingPongMarquee> createState() => _PingPongMarqueeState();
}

class _PingPongMarqueeState extends State<PingPongMarquee> {
  final ScrollController _controller = ScrollController();
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  Future<void> _startScrolling() async {
    while (mounted) {
      await Future.delayed(widget.pauseDuration); // 停顿

      if (!mounted) return;

      final max = _controller.position.maxScrollExtent;
      final min = _controller.position.minScrollExtent;

      if (_isForward) {
        await _controller.animateTo(
          max,
          duration: Duration(milliseconds: (max / widget.speed * 1000).round()),
          curve: Curves.linear,
        );
      } else {
        await _controller.animateTo(
          min,
          duration: Duration(milliseconds: (max / widget.speed * 1000).round()),
          curve: Curves.linear,
        );
      }

      _isForward = !_isForward; // 反向
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PingPongMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _isForward = true;

      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.minScrollExtent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style:
            widget.style ?? const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
