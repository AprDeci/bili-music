import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/common_attach_button.dart';
import 'package:bilimusic/common/components/common_attach_panel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

    return CommonAttachButton(
      enabled: enabled,
      tooltip: tooltip,
      panelBuilder: (_) => _VolumnAttachPanel(
        initialVolume: clampedVolume,
        onVolumeChanged: onVolumeChanged,
        onToggleMute: onToggleMute,
      ),
      child: BarIconButton(
        onPressed: enabled ? () {} : null,
        icon: _volumeIcon(clampedVolume),
        iconSize: iconSize,
        isActive: clampedVolume <= 0,
      ),
    );
  }
}

class _VolumnAttachPanel extends StatefulWidget {
  const _VolumnAttachPanel({
    required this.initialVolume,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final double initialVolume;
  final ValueChanged<double> onVolumeChanged;
  final Future<double> Function() onToggleMute;

  @override
  State<_VolumnAttachPanel> createState() => _VolumnAttachPanelState();
}

class _VolumnAttachPanelState extends State<_VolumnAttachPanel> {
  late double _volume = widget.initialVolume;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double clampedVolume = _volume.clamp(0.0, 1.0).toDouble();
    final int percent = (clampedVolume * 100).round();

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleScroll(event);
        }
      },
      child: CommonAttachPanel(
        width: 72,
        height: 190,
        bodyHeight: 178,
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
                    inactiveTrackColor: colorScheme.outlineVariant.withValues(
                      alpha: 0.7,
                    ),
                    activeTrackColor: colorScheme.primary,
                    thumbColor: colorScheme.primary,
                    overlayColor: colorScheme.primary.withValues(alpha: 0.12),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: clampedVolume,
                    onChanged: _handleVolumeChanged,
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
              onPressed: _handleToggleMute,
              icon: _volumeIcon(clampedVolume),
              iconSize: 20,
              isActive: clampedVolume <= 0,
            ),
          ],
        ),
      ),
    );
  }

  void _handleScroll(PointerScrollEvent event) {
    final double delta = event.scrollDelta.dy > 0 ? -0.05 : 0.05;

    final double newVolume = (_volume + delta).clamp(0.0, 1.0);

    if (newVolume != _volume) {
      setState(() => _volume = newVolume);
      widget.onVolumeChanged(newVolume);
    }
  }

  void _handleVolumeChanged(double value) {
    final double nextVolume = value.clamp(0.0, 1.0).toDouble();
    setState(() => _volume = nextVolume);
    widget.onVolumeChanged(nextVolume);
  }

  Future<void> _handleToggleMute() async {
    final double nextVolume = await widget.onToggleMute();
    setState(() => _volume = nextVolume.clamp(0.0, 1.0).toDouble());
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
