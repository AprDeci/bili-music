import 'package:bilimusic/common/util/screen_util.dart';
import 'package:flutter/material.dart';

class BottomPageSpacer extends StatelessWidget {
  const BottomPageSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil.shouldUseDesktopShell(context)) {
      return const SizedBox.shrink();
    }

    return SizedBox(height: MediaQuery.paddingOf(context).bottom + 16);
  }
}
