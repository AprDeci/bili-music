import 'package:bilimusic/common/components/common_attach_button.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/components/common_attach_panel.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:flutter/material.dart';

class DesktopQualityAttach extends StatelessWidget {
  const DesktopQualityAttach({
    super.key,
    required this.qualities,
    required this.onSelected,
  });

  final List<AudioQualityOption> qualities;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool enabled = qualities.isNotEmpty;
    final List<CommonAttachMenuItem<int?>> items = qualities
        .map((AudioQualityOption option) {
          return CommonAttachMenuItem<int?>(
            value: option.qualityId,
            label: option.label,
            icon: Icons.hd_outlined,
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
        child: CommonAttachMenu<int?>(items: items, onSelected: onSelected),
      ),
      child: _DesktopQualityBadge(isEnabled: enabled),
    );
  }
}

class _DesktopQualityBadge extends StatelessWidget {
  const _DesktopQualityBadge({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.28);

    return SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'SQ',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

double _menuHeight(int itemCount) {
  return itemCount * 44 + (itemCount - 1);
}

double _panelHeight(int itemCount) {
  return _menuHeight(itemCount) + 12;
}
