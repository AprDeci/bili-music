import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/common_attach_button.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/components/common_attach_panel.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:flutter/material.dart';

class DesktopQualityAttach extends StatefulWidget {
  const DesktopQualityAttach({
    super.key,
    required this.qualities,
    required this.onSelected,
  });

  final List<AudioQualityOption> qualities;
  final ValueChanged<int?> onSelected;

  @override
  State<DesktopQualityAttach> createState() => _DesktopQualityAttachState();
}

class _DesktopQualityAttachState extends State<DesktopQualityAttach> {
  String? _pendingBadgeLabel;
  List<AudioQualityOption>? _pendingSourceQualities;

  @override
  void didUpdateWidget(covariant DesktopQualityAttach oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingBadgeLabel != null &&
        !identical(widget.qualities, _pendingSourceQualities) &&
        _hasSelectedQuality(widget.qualities)) {
      _pendingBadgeLabel = null;
      _pendingSourceQualities = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.qualities.isNotEmpty;
    final String badgeLabel =
        _pendingBadgeLabel ?? _qualityBadgeLabel(qualities: widget.qualities);
    final List<CommonAttachMenuItem<int?>> items = widget.qualities
        .map((AudioQualityOption option) {
          return CommonAttachMenuItem<int?>(
            value: option.qualityId,
            label: option.label,
            icon: const SizedBox.shrink(),
            selected: option.isSelected,
          );
        })
        .toList(growable: false);

    return CommonAttachButton(
      enabled: enabled,
      tooltip: '音质',
      panelBuilder: (_) => CommonAttachPanel(
        width: 142,
        height: _panelHeight(items.length),
        bodyHeight: _menuHeight(items.length),
        child: CommonAttachMenu<int?>(
          items: items,
          onSelected: _handleSelected,
        ),
      ),
      child: BarIconButton(
        onPressed: enabled ? () {} : null,
        icon: _DesktopQualityBadge(label: badgeLabel),
        iconSize: 20,
        width: badgeLabel == 'HiRse' ? 44 : 30,
      ),
    );
  }

  void _handleSelected(int? qualityId) {
    AudioQualityOption? selectedOption;
    for (final AudioQualityOption option in widget.qualities) {
      if (option.qualityId == qualityId) {
        selectedOption = option;
        break;
      }
    }

    setState(() {
      _pendingBadgeLabel = _qualityBadgeLabel(
        qualities: selectedOption == null
            ? const <AudioQualityOption>[]
            : <AudioQualityOption>[selectedOption],
      );
      _pendingSourceQualities = widget.qualities;
    });
    widget.onSelected(qualityId);
  }
}

class _DesktopQualityBadge extends StatelessWidget {
  const _DesktopQualityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color color =
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

String _qualityBadgeLabel({required List<AudioQualityOption> qualities}) {
  AudioQualityOption? quality;
  for (final AudioQualityOption option in qualities) {
    if (option.isSelected) {
      quality = option;
      break;
    }
  }

  quality ??= qualities.isEmpty ? null : qualities.first;
  if (quality == null) {
    return 'HQ';
  }

  final String label = quality.label.toLowerCase();
  if (quality.qualityId == 192000 || label.contains('192k')) {
    return 'SQ';
  }

  if (label.contains('hi-res')) {
    return 'HiRse';
  }

  return 'HQ';
}

bool _hasSelectedQuality(List<AudioQualityOption> qualities) {
  for (final AudioQualityOption option in qualities) {
    if (option.isSelected) {
      return true;
    }
  }

  return false;
}

double _menuHeight(int itemCount) {
  return itemCount * 44 + (itemCount - 1);
}

double _panelHeight(int itemCount) {
  return _menuHeight(itemCount) + 12;
}
