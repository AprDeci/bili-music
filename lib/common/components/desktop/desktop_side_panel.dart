import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

const String desktopSidePanelTag = 'desktop_side_panel';

final GlobalKey desktopSidePanelHostKey = GlobalKey(
  debugLabel: 'desktop_side_panel_host',
);

class DesktopSidePanel extends StatelessWidget {
  const DesktopSidePanel({
    super.key,
    required this.child,
    this.height = double.infinity,
    this.width = 420,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        clipBehavior: clipBehavior,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          border: Border(
            left: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

Future<void> showDesktopSidePanel({
  required BuildContext context,
  required WidgetBuilder builder,
  double height = double.infinity,
  double width = 420,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  Color? backgroundColor,
  BorderRadiusGeometry borderRadius = const BorderRadius.all(
    Radius.circular(8),
  ),
  Clip clipBehavior = Clip.antiAlias,
  Color? maskColor,
  bool clickMaskDismiss = true,
  bool keepSingle = true,
  String tag = desktopSidePanelTag,
}) {
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final Size screenSize = mediaQuery.size;
  final Rect? hostRect = _resolveDesktopSidePanelHostRect();
  final double resolvedHeight = hostRect?.height ?? height;
  final double top = hostRect?.top ?? 0;
  final double right = hostRect == null ? 0 : screenSize.width - hostRect.right;

  return SmartDialog.show<void>(
    tag: tag,
    alignment: Alignment.topRight,
    maskColor: maskColor ?? Colors.transparent,
    animationTime: const Duration(milliseconds: 180),
    animationBuilder: (controller, child, animationParam) {
      final Animation<Offset> animation =
          Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          );

      return SlideTransition(position: animation, child: child);
    },
    clickMaskDismiss: clickMaskDismiss,
    keepSingle: keepSingle,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(top: top, right: right),
        child: DesktopSidePanel(
          height: resolvedHeight,
          width: width,
          padding: padding,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          clipBehavior: clipBehavior,
          child: builder(context),
        ),
      );
    },
  );
}

Rect? _resolveDesktopSidePanelHostRect() {
  final BuildContext? context = desktopSidePanelHostKey.currentContext;
  if (context == null) {
    return null;
  }

  final RenderObject? renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    return null;
  }

  final Offset topLeft = renderObject.localToGlobal(Offset.zero);
  return topLeft & renderObject.size;
}
