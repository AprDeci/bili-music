import 'package:flutter/material.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.currentPage,
    required this.onBack,
    required this.onMore,
  });

  final int currentPage;
  final VoidCallback onBack;
  final VoidCallback? onMore;

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
            onPressed: onMore,
            icon: const Icon(Icons.more_vert_rounded),
            color: iconColor,
          ),
        ],
      ),
    );
  }
}

class PlayerPageIndicator extends StatelessWidget {
  const PlayerPageIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(2, (int index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 18 : 6,
          height: 6,
          margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
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
