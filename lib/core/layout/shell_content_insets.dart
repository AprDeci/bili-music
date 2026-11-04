import 'package:flutter/widgets.dart';

class ShellContentInsets extends InheritedWidget {
  const ShellContentInsets({super.key, required super.child});

  static double bottomOf(BuildContext context) {
    final ShellContentInsets? scope = context
        .dependOnInheritedWidgetOfExactType<ShellContentInsets>();
    return scope == null ? 0 : MediaQuery.paddingOf(context).bottom + 16;
  }

  @override
  bool updateShouldNotify(ShellContentInsets oldWidget) => false;
}
