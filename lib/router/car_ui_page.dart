import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:flutter/material.dart';

class CarUiPage extends StatelessWidget {
  const CarUiPage({
    super.key,
    required this.carBuilder,
    required this.standardBuilder,
  });

  final WidgetBuilder carBuilder;
  final WidgetBuilder standardBuilder;

  @override
  Widget build(BuildContext context) =>
      AppLayoutScope.of(context) == AppLayout.car
      ? carBuilder(context)
      : standardBuilder(context);
}
