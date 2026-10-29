import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:popover/popover.dart';

const double _scanPopupWidth = 268;

// popover 锁在 0.4.0：0.5+ 需要 Dart 3.13 / Flutter 3.47（material_ui 拆分）。
// ponytail: 待 Flutter 升到 3.47 后迁 0.5（API 改为 style: PopoverStyle(...)）。

class MetadataViewModeButton extends StatelessWidget {
  const MetadataViewModeButton({
    super.key,
    required this.viewMode,
    required this.onPressed,
  });

  final FavoriteListViewMode viewMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isMetadata = viewMode == FavoriteListViewMode.metadata;
    return Tooltip(
      message: isMetadata ? '切换到视频视图' : '切换到元信息视图',
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        icon: HugeIcon(
          icon: isMetadata
              ? HugeIcons.strokeRoundedMusicNoteSquare01
              : HugeIcons.strokeRoundedPlaySquare,
          size: 22,
          strokeWidth: 1.8,
        ),
      ),
    );
  }
}

class MetadataBackfillButton extends ConsumerWidget {
  const MetadataBackfillButton({super.key, required this.entries});

  final List<FavoriteEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MetadataBackfillState state = ref.watch(
      metadataBackfillControllerProvider,
    );

    return Builder(
      builder: (BuildContext buttonContext) {
        if (state.isRunning) {
          return Tooltip(
            message: '点击停止补齐',
            child: SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () => ref
                    .read(metadataBackfillControllerProvider.notifier)
                    .cancel(),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        return Tooltip(
          message: '补齐/检测元数据',
          child: IconButton(
            onPressed: () => _start(buttonContext, ref),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMagicWand01,
              size: 22,
              strokeWidth: 1.8,
            ),
          ),
        );
      },
    );
  }

  void _start(BuildContext buttonContext, WidgetRef ref) {
    unawaited(
      ref
          .read(metadataBackfillControllerProvider.notifier)
          .backfillMissing(
            entries.map((FavoriteEntry entry) => entry.toPlayableItem()),
          ),
    );
    if (!buttonContext.mounted) {
      return;
    }

    final Color primary = Theme.of(buttonContext).colorScheme.primary;
    showPopover<void>(
      context: buttonContext,
      direction: PopoverDirection.bottom,
      width: _scanPopupWidth,
      backgroundColor: primary,
      barrierColor: Colors.transparent,
      radius: 12,
      arrowWidth: 16,
      arrowHeight: 8,
      transition: PopoverTransition.other,
      shadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.24),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      bodyBuilder: (_) => MetadataScanPopup(foundCount: entries.length),
    );
  }
}

class MetadataScanPopup extends ConsumerWidget {
  const MetadataScanPopup({super.key, required this.foundCount});

  final int foundCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MetadataBackfillState state = ref.watch(
      metadataBackfillControllerProvider,
    );

    final int pending = (state.total - state.processed).clamp(0, state.total);
    final String title = state.isRunning ? '正在扫描' : '扫描完成';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          Text(
            '已找到 $foundCount，待更新 $pending，已更新 ${state.matched}',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
