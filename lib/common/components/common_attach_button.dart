import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CommonAttachButton extends StatelessWidget {
  const CommonAttachButton({
    super.key,
    required this.child,
    required this.panelBuilder,
    this.enabled = true,
    this.tooltip,
    this.alignment = Alignment.topCenter,
    this.offset = const EdgeInsets.only(bottom: 8),
    this.keepSingle = true,
    this.dismissOnMaskTap = true,
  });

  final Widget child;
  final WidgetBuilder panelBuilder;
  final bool enabled;
  final String? tooltip;
  final Alignment alignment;
  final EdgeInsets offset;
  final bool keepSingle;
  final bool dismissOnMaskTap;

  @override
  Widget build(BuildContext context) {
    final Widget button = Builder(
      builder: (BuildContext targetContext) {
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerUp: enabled ? (_) => _showAttach(targetContext) : null,
          child: child,
        );
      },
    );

    final String? message = tooltip;
    if (message == null) {
      return button;
    }

    return Tooltip(
      waitDuration: const Duration(milliseconds: 600),
      message: message,
      child: button,
    );
  }

  void _showAttach(BuildContext targetContext) {
    SmartDialog.showAttach<void>(
      maskColor: Colors.black.withValues(alpha: 0),
      targetContext: targetContext,
      alignment: alignment,
      animationType: SmartAnimationType.scale,
      keepSingle: keepSingle,
      clickMaskDismiss: dismissOnMaskTap,
      scalePointBuilder: (Size selfSize) {
        return Offset(selfSize.width / 2, selfSize.height);
      },
      adjustBuilder: (AttachParam attachParam) {
        return AttachAdjustParam(
          builder: (_) {
            return Padding(padding: offset, child: attachParam.selfWidget);
          },
        );
      },
      builder: panelBuilder,
    );
  }
}
