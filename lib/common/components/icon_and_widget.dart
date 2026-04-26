import 'package:flutter/material.dart';

class IconAndWidget extends StatelessWidget {
  const IconAndWidget({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  final Object icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Object icon = this.icon;

    if (icon is IconData) {
      return Icon(icon, size: size, color: color);
    }

    if (icon is Widget) {
      return IconTheme.merge(
        data: IconThemeData(size: size, color: color),
        child: icon,
      );
    }

    throw ArgumentError.value(icon, 'icon', 'must be IconData or Widget');
  }
}
