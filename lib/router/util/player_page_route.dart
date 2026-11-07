import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayerPageRoute extends PageRouteBuilder<void> {
  PlayerPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        allowSnapshotting: false,
        pageBuilder: (context, _, _) => builder(context),
      );

  NavigatorState? _gestureNavigator;
  bool _settling = false;

  bool get canStartDrag =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      isCurrent &&
      !isFirst &&
      popDisposition == RoutePopDisposition.pop &&
      controller?.status == AnimationStatus.completed &&
      _gestureNavigator == null;

  bool startDrag() {
    if (!canStartDrag) {
      return false;
    }
    _gestureNavigator = navigator;
    _gestureNavigator!.didStartUserGesture();
    return true;
  }

  void updateDrag(double fraction) {
    if (_gestureNavigator == null || _settling) {
      return;
    }
    if (!isCurrent) {
      endDrag();
      return;
    }
    controller!.value = (1 - fraction).clamp(0.001, 1.0);
  }

  Future<void> endDrag({bool dismiss = false}) async {
    if (_gestureNavigator == null || _settling) {
      return;
    }
    _settling = true;
    final AnimationController animationController = controller!;
    try {
      final bool shouldPop =
          dismiss && isCurrent && popDisposition == RoutePopDisposition.pop;
      if (shouldPop) {
        navigator!.pop();
      }
      if (!isActive || shouldPop) {
        await animationController
            .animateBack(
              0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            )
            .orCancel;
      } else {
        await animationController
            .animateTo(
              1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            )
            .orCancel;
      }
    } on TickerCanceled {
      return;
    } finally {
      _stopGesture();
    }
  }

  void _stopGesture() {
    final NavigatorState? gestureNavigator = _gestureNavigator;
    _gestureNavigator = null;
    _settling = false;
    gestureNavigator?.didStopUserGesture();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final double progress = _gestureNavigator != null
        ? animation.value
        : (animation.status == AnimationStatus.reverse
                  ? Curves.easeInCubic
                  : Curves.easeOutCubic)
              .transform(animation.value);
    return FractionalTranslation(
      translation: Offset(0, 1 - progress),
      child: child,
    );
  }

  @override
  void dispose() {
    _stopGesture();
    super.dispose();
  }
}
