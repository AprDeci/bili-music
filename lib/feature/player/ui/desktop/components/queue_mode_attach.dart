import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/common_attach_button.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/components/common_attach_panel.dart';
import 'package:bilimusic/common/components/queue_mode_icon.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopQueueModeAttach extends StatelessWidget {
  const DesktopQueueModeAttach({
    super.key,
    required this.mode,
    required this.onSelected,
    this.enabled = true,
    this.iconSize = 20,
  });

  final PlayerQueueMode mode;
  final ValueChanged<PlayerQueueMode> onSelected;
  final bool enabled;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final List<CommonAttachMenuItem<PlayerQueueMode>> items =
        <CommonAttachMenuItem<PlayerQueueMode>>[
          CommonAttachMenuItem<PlayerQueueMode>(
            value: PlayerQueueMode.shuffle,
            label: '随机播放',
            icon: HugeIcon(icon: HugeIcons.strokeRoundedShuffle, size: 19),
            selected: mode == PlayerQueueMode.shuffle,
          ),
          CommonAttachMenuItem<PlayerQueueMode>(
            value: PlayerQueueMode.sequence,
            label: '顺序播放',
            icon: HugeIcon(icon: HugeIcons.strokeRoundedRepeat, size: 19),
            selected: mode == PlayerQueueMode.sequence,
          ),
          CommonAttachMenuItem<PlayerQueueMode>(
            value: PlayerQueueMode.singleRepeat,
            label: '单曲循环',
            icon: HugeIcon(icon: HugeIcons.strokeRoundedRepeatOne01, size: 19),
            selected: mode == PlayerQueueMode.singleRepeat,
          ),
        ];

    return CommonAttachButton(
      enabled: enabled,
      tooltip: '播放模式',
      panelBuilder: (_) => CommonAttachPanel(
        width: 142,
        height: _panelHeight(items.length),
        bodyHeight: _menuHeight(items.length),
        child: CommonAttachMenu<PlayerQueueMode>(
          items: items,
          onSelected: onSelected,
        ),
      ),
      child: BarIconButton(
        onPressed: enabled ? () {} : null,
        icon: queueModeIcon(mode),
        iconSize: iconSize,
        isActive: false,
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
