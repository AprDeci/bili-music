import 'package:flutter/material.dart';

Future<T?> showCarSidePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: true).context,
  );
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, _, _) => themes.wrap(
      SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: CarSidePanel(child: Builder(builder: builder)),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
      child: child,
    ),
  );
}

class CarSidePanel extends StatelessWidget {
  const CarSidePanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: (constraints.maxWidth * 0.6)
            .clamp(480.0, 760.0)
            .clamp(0.0, constraints.maxWidth),
        height: constraints.maxHeight,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
