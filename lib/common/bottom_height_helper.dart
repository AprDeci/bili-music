import 'package:flutter/material.dart';

class BottomHeightHelper {
  static const double bottomBarHeight = 60;
  static const double miniPlayerBarHeight = 72;
  static const double miniPlayerGapWithBottomBar = 10;
  static const double miniPlayerGapWithoutBottomBar = 20;
  static const double contentBottomGap = 16;

  static const double miniPlayerVisibleBottomPadding =
      bottomBarHeight + miniPlayerGapWithBottomBar;
  static const double miniPlayerCollapsedBottomPadding =
      miniPlayerGapWithoutBottomBar;

  static double miniPlayerBottomPaddingWithBottomBar({double bottomInset = 0}) {
    return bottomInset + miniPlayerVisibleBottomPadding;
  }

  static double miniPlayerBottomPaddingWithoutBottomBar({
    double bottomInset = 0,
  }) {
    return bottomInset + miniPlayerCollapsedBottomPadding;
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
