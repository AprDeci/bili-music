import 'package:bilimusic/core/layout/shell_content_insets.dart';
import 'package:flutter/material.dart';

class BottomPageSpacer extends StatelessWidget {
  const BottomPageSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: ShellContentInsets.bottomOf(context));
  }
}
