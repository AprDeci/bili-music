import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/components/underline_tab_switcher.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showPlayerJumpSelector({
  required BuildContext context,
  required PlayerState state,
  required PlayerController controller,
  VoidCallback? onDownloadAll,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (BuildContext context) => SafeArea(
    child: _PlayerJumpSelectorContent(
      state: state,
      controller: controller,
      onDownloadAll: onDownloadAll,
      onClose: () async => Navigator.of(context).pop(),
    ),
  ),
);

Future<void> showDesktopPlayerJumpSelectorPanel({
  required BuildContext context,
  required PlayerState state,
  required PlayerController controller,
  VoidCallback? onDownloadAll,
}) => showDesktopSidePanel(
  tag: 'player_jump_selector',
  context: context,
  width: 420,
  builder: (BuildContext context) => SafeArea(
    child: _PlayerJumpSelectorContent(
      state: state,
      controller: controller,
      onDownloadAll: onDownloadAll,
      onClose: () => SmartDialog.dismiss<void>(tag: 'player_jump_selector'),
    ),
  ),
);

enum _JumpTab { chapters, parts }

class _PlayerJumpSelectorContent extends StatefulWidget {
  const _PlayerJumpSelectorContent({
    required this.state,
    required this.controller,
    required this.onClose,
    this.onDownloadAll,
  });

  final PlayerState state;
  final PlayerController controller;
  final Future<void> Function() onClose;
  final VoidCallback? onDownloadAll;

  @override
  State<_PlayerJumpSelectorContent> createState() =>
      _PlayerJumpSelectorContentState();
}

class _PlayerJumpSelectorContentState
    extends State<_PlayerJumpSelectorContent> {
  _JumpTab _tab = _JumpTab.chapters;

  @override
  Widget build(BuildContext context) {
    final PlayerState state = widget.state;
    final bool hasChapters = state.chapters.length > 1;
    final bool hasParts = state.availableParts.length > 1;
    final _JumpTab tab = hasChapters ? _tab : _JumpTab.parts;

    return Column(
      children: <Widget>[
        if (hasChapters && hasParts)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: UnderlineTabSwitcher(
                labels: const <String>['章节', '分P'],
                selectedIndex: tab.index,
                minimumSize: const Size(24, 48),
                textStyle: Theme.of(context).textTheme.titleSmall,
                onChanged: (int index) =>
                    setState(() => _tab = _JumpTab.values[index]),
              ),
            ),
          ),
        Expanded(
          child: tab == _JumpTab.chapters
              ? PlayerChapterSelectorContent(
                  chapters: state.chapters,
                  position: state.position,
                  isPlaying: state.isPlaying,
                  onSeek: widget.controller.seek,
                  onClose: widget.onClose,
                )
              : PlayerPartSelectorContent(
                  parts: state.availableParts,
                  currentItem: state.currentItem!,
                  state: state,
                  controller: widget.controller,
                  onDownloadAll: widget.onDownloadAll,
                  onClose: widget.onClose,
                ),
        ),
      ],
    );
  }
}
