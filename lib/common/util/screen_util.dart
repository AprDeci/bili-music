import 'package:bilimusic/common/util/platform_util.dart';
import 'package:flutter/material.dart';

class ScreenUtil {
  static const double desktopBreakpoint = 960;

  static Size screenSize(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static double screenWidth(BuildContext context) {
    return screenSize(context).width;
  }

  static bool isDesktopWidth(BuildContext context) {
    return screenWidth(context) >= desktopBreakpoint;
  }

  static bool shouldUseDesktopShell(BuildContext context) {
    return PlatformUtil.isDesktop && isDesktopWidth(context);
  }
}
