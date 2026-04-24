import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/util/screen_util.dart';
import 'package:flutter/material.dart';

enum BottomPageSpacerType { tab, overlay }

class BottomPageSpacer extends StatelessWidget {
  const BottomPageSpacer.tab({super.key}) : type = BottomPageSpacerType.tab;

  const BottomPageSpacer.overlay({super.key})
    : type = BottomPageSpacerType.overlay;

  final BottomPageSpacerType type;

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil.shouldUseDesktopShell(context)) {
      return const SizedBox.shrink();
    }

    final double height = switch (type) {
      BottomPageSpacerType.tab => BottomHeightHelper.tabPageBottomSpacing(
        context,
      ),
      BottomPageSpacerType.overlay =>
        BottomHeightHelper.overlayPageBottomSpacing(context),
    };

    return SizedBox(height: height);
  }
}
