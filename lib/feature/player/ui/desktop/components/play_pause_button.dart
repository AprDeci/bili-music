import 'package:flutter/material.dart';

class DesktopPlayPauseButton extends StatelessWidget {
  const DesktopPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.showTooltip = true,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
  });

  final bool isPlaying;
  final bool? showTooltip;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: showTooltip == true ? (isPlaying ? '暂停' : '播放') : null,
      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
      iconSize: 22,
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 30),
        maximumSize: const Size(40, 30),
        padding: EdgeInsets.zero,
        backgroundColor: backgroundColor ?? colorScheme.primary,
        disabledBackgroundColor:
            disabledBackgroundColor ?? colorScheme.surfaceContainerHighest,
        foregroundColor: foregroundColor ?? colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        enabledMouseCursor: SystemMouseCursors.click,
      ),
    );
  }
}
