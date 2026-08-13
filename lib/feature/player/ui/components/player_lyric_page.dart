import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_offset_sheet.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_search_sheet.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerLyricPage extends ConsumerStatefulWidget {
  const PlayerLyricPage({
    super.key,
    required this.state,
    required this.item,
    required this.isActive,
    required this.onSeek,
    this.activeColor,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;

  @override
  ConsumerState<PlayerLyricPage> createState() => _PlayerLyricPageState();
}

class _PlayerLyricPageState extends ConsumerState<PlayerLyricPage> {
  bool _showTranslation = true;

  @override
  Widget build(BuildContext context) {
    final MetadataState metadataState = ref.watch(metadataControllerProvider);
    final PlayableItem? item = widget.item;
    final String translationLyrics =
        resolveDisplayTranslationLyrics(metadataState.metadata)?.trim() ?? '';
    final bool canToggleTranslation =
        metadataState.stableId == item?.stableId &&
        translationLyrics.isNotEmpty;

    final Widget content = _PlayerLyricPanelHost(
      baseState: widget.state,
      item: item,
      isActive: widget.isActive,
      onSeek: widget.onSeek,
      activeColor: widget.activeColor,
      showTranslation: _showTranslation,
    );
    if (item == null) {
      return content;
    }

    return Column(
      children: <Widget>[
        Expanded(child: content),
        _PlayerLyricToolbar(
          activeColor: ColorUtil.getAllShades(widget.activeColor!)[600]!,
          onSearch: () => showManualLyricSearchSheet(
            context: context,
            initialKeyword: resolveLyricSearchKeyword(
              metadataState: metadataState,
              item: item,
            ),
          ),
          onOffset: () => showLyricOffsetSheet(context),
          showTranslation: _showTranslation,
          toggleTranslation: canToggleTranslation
              ? () => setState(() => _showTranslation = !_showTranslation)
              : null,
        ),
      ],
    );
  }
}

class _PlayerLyricPanelHost extends ConsumerWidget {
  const _PlayerLyricPanelHost({
    required this.baseState,
    required this.item,
    required this.isActive,
    required this.onSeek,
    required this.showTranslation,
    this.activeColor,
  });

  final PlayerState baseState;
  final PlayableItem? item;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final bool showTranslation;
  final Color? activeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlayerProgressSnapshot> progressAsync = ref.watch(
      playerProgressProvider,
    );
    final PlayerProgressSnapshot progress = resolvePlayerProgressSnapshot(
      progressAsync,
      baseState,
    );

    return PlayerLyricPanel(
      state: baseState.copyWith(
        position: progress.position,
        duration: progress.duration,
      ),
      item: item,
      isActive: isActive,
      onSeek: onSeek,
      activeColor: activeColor,
      showTranslation: showTranslation,
    );
  }
}

class _PlayerLyricToolbar extends StatelessWidget {
  const _PlayerLyricToolbar({
    required this.activeColor,
    this.onOffset,
    this.onSearch,
    this.toggleTranslation,
    required this.showTranslation,
  });

  final Color activeColor;
  final VoidCallback? onSearch;
  final VoidCallback? onOffset;
  final VoidCallback? toggleTranslation;
  final bool showTranslation;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = activeColor;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              tooltip: '手动匹配歌词',
              onPressed: onSearch,
              color: iconColor,
              icon: const Icon(Icons.search_rounded),
            ),
            const SizedBox(width: 20),
            IconButton(
              tooltip: '歌词偏移',
              onPressed: onOffset,
              color: iconColor,
              icon: const Icon(Icons.hourglass_empty_rounded),
            ),
            if (toggleTranslation != null) ...<Widget>[
              const SizedBox(width: 20),
              IconButton(
                tooltip: showTranslation ? '隐藏译文' : '显示译文',
                onPressed: toggleTranslation,
                color: iconColor.withValues(alpha: showTranslation ? 1 : 0.45),
                icon: const Icon(BmIcons.translate, size: 30),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
