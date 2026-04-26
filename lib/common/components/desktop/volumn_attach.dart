import 'dart:math' as math;

import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopVolumnAttach extends StatelessWidget {
  const DesktopVolumnAttach({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
    required this.onToggleMute,
    this.enabled = true,
    this.tooltip = '音量',
    this.iconSize = 20,
  });

  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final Future<double> Function() onToggleMute;
  final bool enabled;
  final String tooltip;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final double clampedVolume = volume.clamp(0.0, 1.0).toDouble();

    return Builder(
      builder: (BuildContext targetContext) {
        return Tooltip(
          waitDuration: const Duration(milliseconds: 600),
          message: tooltip,
          child: BarIconButton(
            onPressed: enabled
                ? () => _showAttach(targetContext, clampedVolume)
                : null,
            icon: _volumeIcon(clampedVolume),
            iconSize: iconSize,
            isActive: clampedVolume <= 0,
          ),
        );
      },
    );
  }

  void _showAttach(BuildContext targetContext, double initialVolume) {
    double panelVolume = initialVolume;

    SmartDialog.showAttach<void>(
      maskColor: Colors.black.withValues(alpha: 0),
      targetContext: targetContext,
      alignment: Alignment.topCenter,
      animationType: SmartAnimationType.scale,
      keepSingle: true,
      clickMaskDismiss: true,
      scalePointBuilder: (Size selfSize) {
        return Offset(selfSize.width / 2, selfSize.height);
      },
      adjustBuilder: (AttachParam attachParam) {
        return AttachAdjustParam(
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: attachParam.selfWidget,
            );
          },
        );
      },
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _VolumnAttachPanel(
              volume: panelVolume,
              onVolumeChanged: (double value) {
                final double nextVolume = value.clamp(0.0, 1.0).toDouble();
                setState(() => panelVolume = nextVolume);
                onVolumeChanged(nextVolume);
              },
              onToggleMute: () async {
                final double nextVolume = await onToggleMute();
                setState(() => panelVolume = nextVolume.clamp(0.0, 1.0));
              },
            );
          },
        );
      },
    );
  }
}

class _VolumnAttachPanel extends StatelessWidget {
  const _VolumnAttachPanel({
    required this.volume,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final Future<void> Function() onToggleMute;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double clampedVolume = volume.clamp(0.0, 1.0).toDouble();
    final int percent = (clampedVolume * 100).round();

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 72,
        height: 190,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              bottom: 8,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 72,
                height: 178,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 104,
                      width: 38,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.5,
                            inactiveTrackColor: colorScheme.outlineVariant
                                .withValues(alpha: 0.7),
                            activeTrackColor: colorScheme.primary,
                            thumbColor: colorScheme.primary,
                            overlayColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                          ),
                          child: Slider(
                            value: clampedVolume,
                            onChanged: onVolumeChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$percent%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BarIconButton(
                      onPressed: onToggleMute,
                      icon: _volumeIcon(clampedVolume),
                      iconSize: 20,
                      isActive: clampedVolume <= 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

HugeIcon _volumeIcon(double volume) {
  if (volume <= 0) {
    return HugeIcon(icon: HugeIcons.strokeRoundedVolumeMute02, size: 22);
  }
  if (volume < 0.5) {
    return HugeIcon(icon: HugeIcons.strokeRoundedVolumeLow, size: 22);
  }
  return HugeIcon(icon: HugeIcons.strokeRoundedVolumeHigh, size: 22);
}
