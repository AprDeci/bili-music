import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.state,
    required this.onTap,
    required this.onTogglePlayback,
    this.bottomPadding = BottomHeightHelper.miniPlayerCollapsedBottomPadding,
  });

  final PlayerState state;
  final VoidCallback onTap;
  final VoidCallback onTogglePlayback;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String subtitle = _buildSubtitle(state);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  _Artwork(coverUrl: state.currentItem?.coverUrl ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.currentItem?.title ?? '未选择播放内容',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onTogglePlayback,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      foregroundColor: colorScheme.primary,
                    ),
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(PlayerState state) {
    return switch (state.statusHint) {
      PlayerStatusHint.resolvingAudio => '正在解析音频...',
      PlayerStatusHint.connectingStream => '正在连接播放流...',
      PlayerStatusHint.loadingCache => '正在加载缓存音频...',
      PlayerStatusHint.buffering => '缓冲中...',
      PlayerStatusHint.error => state.errorMessage ?? '播放失败，请稍后重试',
      null =>
        state.audioStream?.qualityLabel ?? state.currentItem?.author ?? '',
    };
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CommonCachedImage(
          imageUrl: coverUrl,
          fit: BoxFit.cover,
          fallbackIcon: Icons.music_note_rounded,
          iconColor: colorScheme.onSurfaceVariant,
          backgroundColor: colorScheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}
