import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/common_attach_button.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/components/common_attach_panel.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/ui/components/player_quality_badge.dart';
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
        hasSelectedQuality(widget.qualities)) {
      _pendingBadgeLabel = null;
      _pendingSourceQualities = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.qualities.isNotEmpty;
    final String badgeLabel =
        _pendingBadgeLabel ?? qualityBadgeLabel(qualities: widget.qualities);
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
        icon: PlayerQualityBadge(label: badgeLabel),
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
      _pendingBadgeLabel = qualityBadgeLabel(
        qualities: selectedOption == null
            ? const <AudioQualityOption>[]
            : <AudioQualityOption>[selectedOption],
      );
      _pendingSourceQualities = widget.qualities;
    });
    widget.onSelected(qualityId);
  }
}

double _menuHeight(int itemCount) {
  return itemCount * 44 + (itemCount - 1);
}

double _panelHeight(int itemCount) {
  return _menuHeight(itemCount) + 12;
}
