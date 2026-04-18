import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle normalStyle;
  final TextStyle highlightStyle;
  final bool caseSensitive;

  const HighlightText({
    super.key,
    required this.text,
    required this.highlight,
    this.normalStyle = const TextStyle(color: Colors.black),
    this.highlightStyle = const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
    ),
    this.caseSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (highlight.isEmpty) {
      return Text(text, style: normalStyle);
    }

    final sourceText = caseSensitive ? text : text.toLowerCase();
    final targetText = caseSensitive ? highlight : highlight.toLowerCase();

    final matches = <TextSpan>[];
    int start = 0;
    int index = sourceText.indexOf(targetText);

    while (index != -1) {
      // 添加高亮前的文本
      if (index > start) {
        matches.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      // 添加高亮文本
      matches.add(
        TextSpan(
          text: text.substring(index, index + highlight.length),
          style: highlightStyle,
        ),
      );

      start = index + highlight.length;
      index = sourceText.indexOf(targetText, start);
    }

    // 添加剩余文本
    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start), style: normalStyle));
    }

    return matches.isEmpty
        ? Text(text, style: normalStyle)
        : Text.rich(TextSpan(children: matches));
  }
}
