import 'package:flutter/material.dart';

class BottomHeightHelper {
  static const double bottomBarHeight = 60;
  static const double miniPlayerBarHeight = 56;
  static const double bottomBarFloatingOffset = 10;
  static const double miniPlayerGapWithBottomBar = 10;
  static const double miniPlayerGapWithoutBottomBar = 20;
  static const double contentBottomGap = 16;

  static double bottomBarOffset({double bottomInset = 0}) {
    return bottomInset > 0 ? bottomInset : bottomBarFloatingOffset;
  }

  static double miniPlayerBottomPaddingWithBottomBar({
    double bottomInset = 0,
    double? bottomBarOffset,
  }) {
    final double effectiveBottomBarOffset =
        bottomBarOffset ??
        BottomHeightHelper.bottomBarOffset(bottomInset: bottomInset);

    return effectiveBottomBarOffset +
        bottomBarHeight +
        miniPlayerGapWithBottomBar;
  }

  static double miniPlayerBottomPaddingWithoutBottomBar({
    double bottomInset = 0,
  }) {
    return bottomInset + miniPlayerGapWithoutBottomBar;
  }

  static double miniPlayerOccupiedHeightWithBottomBar({
    double bottomInset = 0,
  }) {
    return miniPlayerBarHeight +
        miniPlayerBottomPaddingWithBottomBar(bottomInset: bottomInset);
  }

  static double miniPlayerOccupiedHeightWithoutBottomBar({
    double bottomInset = 0,
  }) {
    return miniPlayerBarHeight +
        miniPlayerBottomPaddingWithoutBottomBar(bottomInset: bottomInset);
  }

  static double tabPageBottomSpacing(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return miniPlayerOccupiedHeightWithBottomBar(bottomInset: bottomInset) +
        contentBottomGap;
  }

  static double overlayPageBottomSpacing(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return miniPlayerOccupiedHeightWithoutBottomBar(bottomInset: bottomInset) +
        contentBottomGap;
  }
}
