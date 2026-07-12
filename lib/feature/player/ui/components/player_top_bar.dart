import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.currentPage,
    required this.onBack,
    required this.onOpenMenu,
  });

  final int currentPage;
  final VoidCallback onBack;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          Expanded(
            child: Center(child: PlayerPageIndicator(currentPage: currentPage)),
          ),
          IconButton(
            onPressed: onOpenMenu,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedMenu01, size: 20),
          ),
        ],
      ),
    );
  }
}

class PlayerPageIndicator extends StatelessWidget {
  const PlayerPageIndicator({
    super.key,
    required this.currentPage,
    this.pageCount = 3,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final neutralColor = neutralColorOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(pageCount, (int index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 12 : 3,
          height: 3,
          margin: EdgeInsets.only(right: index < pageCount - 1 ? 8 : 0),
          decoration: BoxDecoration(
            color: isActive
                ? neutralColor
                : neutralColor.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
