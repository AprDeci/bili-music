import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_offset_sheet.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_search_sheet.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_settings_sheet.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_subtitle_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerLyricPage extends ConsumerWidget {
  const PlayerLyricPage({
    super.key,
    required this.state,
    required this.item,
    required this.isActive,
    required this.onSeek,
    this.activeColor,
    this.showToolbar = true,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final bool showToolbar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showTranslation = ref.watch(
      playerLyricSettingsLogicProvider.select(
        (settings) => settings.showTranslation,
      ),
    );
    final PlayableItem? item = this.item;
    final bool isSpoken = item?.isSpoken ?? false;
    final MetadataState metadataState = isSpoken
        ? const MetadataState()
        : ref.watch(metadataControllerProvider);
    final PlayerSubtitleState subtitleState = ref.watch(
      playerSubtitleControllerProvider,
    );
    final bool usesSubtitles =
        subtitleState.stableId == item?.stableId && subtitleState.usesSubtitles;
    final bool canSelectSubtitles =
        subtitleState.stableId == item?.stableId && subtitleState.hasTracks;
    final String translationLyrics =
        resolveDisplayTranslationLyrics(metadataState.metadata)?.trim() ?? '';
    final bool canToggleTranslation =
        !usesSubtitles &&
        metadataState.stableId == item?.stableId &&
        translationLyrics.isNotEmpty;

    final Widget content = _PlayerLyricPanelHost(
      baseState: state,
      item: item,
      isActive: isActive,
      onSeek: onSeek,
      activeColor: activeColor,
      showTranslation: showTranslation && !usesSubtitles,
    );
    if (item == null || !showToolbar) {
      return content;
    }

    return Column(
      children: <Widget>[
        Expanded(child: content),
        _PlayerLyricToolbar(
          activeColor: ColorUtil.getAllShades(
            activeColor ?? Theme.of(context).colorScheme.primary,
          )[600]!,
          onSearch: isSpoken
              ? null
              : () {
                  ref
                      .read(playerSubtitleControllerProvider.notifier)
                      .useMeting();
                  showManualLyricSearchSheet(
                    context: context,
                    initialKeyword: resolveLyricSearchKeyword(
                      metadataState: metadataState,
                      item: item,
                    ),
                  );
                },
          onSubtitles: canSelectSubtitles
              ? () => showPlayerSubtitleSheet(context)
              : null,
          onOffset: isSpoken && !usesSubtitles
              ? null
              : () => showLyricOffsetSheet(context),
          onAppearance: () =>
              showPlayerLyricSettings(context, activeColor: activeColor),
          showTranslation: showTranslation,
          toggleTranslation: canToggleTranslation
              ? () async {
                  try {
                    await ref
                        .read(playerLyricSettingsLogicProvider.notifier)
                        .setShowTranslation(!showTranslation);
                  } on Object {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('译文设置保存失败，请重试')),
                      );
                    }
                  }
                }
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
    final PlayerProgressSnapshot progress = isActive
        ? ref.watch(
            playerControllerProvider.select(
              (state) => (
                position: state.position,
                duration: state.duration,
                isReady: state.isReady,
              ),
            ),
          )
        : resolvePlayerProgressSnapshot(
            ref.watch(playerProgressProvider),
            ref.read(playerControllerProvider),
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
    this.onAppearance,
    this.onSearch,
    this.toggleTranslation,
    this.onSubtitles,
    required this.showTranslation,
  });

  final Color activeColor;
  final VoidCallback? onSearch;
  final VoidCallback? onOffset;
  final VoidCallback? onAppearance;
  final VoidCallback? toggleTranslation;
  final VoidCallback? onSubtitles;
  final bool showTranslation;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = activeColor;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (onSearch != null)
                  IconButton(
                    tooltip: '手动匹配歌词',
                    onPressed: onSearch,
                    color: iconColor,
                    icon: const Icon(Icons.search_rounded),
                  ),
                const SizedBox(width: 20),
                if (onOffset != null)
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
                    color: iconColor.withValues(
                      alpha: showTranslation ? 1 : 0.45,
                    ),
                    icon: const Icon(BmIcons.translate, size: 30),
                  ),
                ],
                if (onSubtitles != null) ...<Widget>[
                  const SizedBox(width: 20),
                  IconButton(
                    tooltip: 'AI字幕',
                    onPressed: onSubtitles,
                    color: iconColor,
                    icon: const Icon(Icons.subtitles_outlined),
                  ),
                ],
                const SizedBox(width: 20),
                IconButton(
                  tooltip: '歌词外观',
                  onPressed: onAppearance,
                  color: iconColor,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPreferenceHorizontal,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
