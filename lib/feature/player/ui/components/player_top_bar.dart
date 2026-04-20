import 'package:flutter/material.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.currentPage,
    required this.onBack,
    required this.onOpenInBrowser,
  });

  final int currentPage;
  final VoidCallback onBack;
  final VoidCallback? onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.primary;

    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            color: iconColor,
          ),
          Expanded(
            child: Center(child: PlayerPageIndicator(currentPage: currentPage)),
          ),
          IconButton(
            onPressed: onOpenInBrowser,
            icon: const Icon(Icons.ios_share_outlined),
            color: iconColor,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(pageCount, (int index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 18 : 6,
          height: 6,
          margin: EdgeInsets.only(right: index < pageCount - 1 ? 8 : 0),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
