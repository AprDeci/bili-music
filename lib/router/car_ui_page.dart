import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarUiPage extends ConsumerWidget {
  const CarUiPage({
    super.key,
    required this.carBuilder,
    required this.standardBuilder,
  });

  final WidgetBuilder carBuilder;
  final WidgetBuilder standardBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(carUiSettingLogicProvider)
      ? carBuilder(context)
      : standardBuilder(context);
}
