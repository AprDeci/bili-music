import 'package:flutter/material.dart';

Future<T?> showCarSidePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? width,
  double? height,
  Alignment alignment = Alignment.centerLeft,
  Offset slideFrom = const Offset(-1, 0),
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
          alignment: alignment,
          child: CarSidePanel(
            width: width,
            height: height,
            child: Builder(builder: builder),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: slideFrom,
        end: Offset.zero,
      ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
      child: child,
    ),
  );
}

class CarSidePanel extends StatelessWidget {
  const CarSidePanel({super.key, required this.child, this.width, this.height})
    : assert(width == null || (width >= 0 && width < double.infinity)),
      assert(height == null || (height >= 0 && height < double.infinity));

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.constrainWidth(
          width ?? (constraints.maxWidth * 0.6).clamp(480.0, 760.0),
        ),
        height: constraints.constrainHeight(height ?? constraints.maxHeight),
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
