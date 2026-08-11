import 'package:flutter/material.dart';

enum TagSize { small, medium, large }

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.size = TagSize.medium,
    this.textColor = Colors.white,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.iconSpacing,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final Color color;
  final Widget? icon;
  final TagSize size;
  final Color textColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double? iconSpacing;
  final int? maxLines;
  final TextOverflow? overflow;

  EdgeInsetsGeometry get _padding {
    if (padding != null) {
      return padding!;
    }

    return switch (size) {
      TagSize.small => const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      TagSize.medium => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      TagSize.large => const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    };
  }

  double get _fontSize {
    return switch (size) {
      TagSize.small => 10,
      TagSize.medium => 12,
      TagSize.large => 14,
    };
  }

  double get _iconSpacing {
    return iconSpacing ??
        switch (size) {
          TagSize.small => 4,
          TagSize.medium => 4,
          TagSize.large => 6,
        };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: _iconSpacing)],
          Text(
            text,
            maxLines: maxLines,
            overflow: overflow,
            style: TextStyle(
              fontSize: _fontSize,
              color: textColor,
            ).merge(textStyle),
          ),
        ],
      ),
    );
  }
}
