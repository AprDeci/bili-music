import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPlayerSubtitleSheet(BuildContext context) async {
  final ProviderContainer container = ProviderScope.containerOf(
    context,
    listen: false,
  );
  final String? stableId = container
      .read(playerControllerProvider)
      .currentItem
      ?.stableId;
  if (stableId == null ||
      container.read(playerSubtitleControllerProvider).stableId != stableId) {
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (BuildContext context) => _PlayerSubtitleSheet(stableId: stableId),
  );
}

class _PlayerSubtitleSheet extends ConsumerWidget {
  const _PlayerSubtitleSheet({required this.stableId});

  final String stableId;

  bool _isCurrent(WidgetRef ref) =>
      ref.read(playerControllerProvider).currentItem?.stableId == stableId &&
      ref.read(playerSubtitleControllerProvider).stableId == stableId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerSubtitleState state = ref.watch(
      playerSubtitleControllerProvider,
    );
    final currentItem = ref.watch(
      playerControllerProvider.select((value) => value.currentItem),
    );
    final bool isCurrent =
        currentItem?.stableId == stableId && state.stableId == stableId;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text('字幕', style: Theme.of(context).textTheme.titleLarge),
            ),
            if (!isCurrent)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('当前歌曲已变更，请重新打开字幕选择'),
              ),
            ListTile(
              title: Text(currentItem?.isSpoken == true ? '关闭字幕' : 'Meting歌词'),
              selected: isCurrent && !state.usesSubtitles,
              trailing: isCurrent && !state.usesSubtitles
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
                  : null,
              onTap: !isCurrent
                  ? null
                  : () {
                      if (!_isCurrent(ref)) return;
                      ref
                          .read(playerSubtitleControllerProvider.notifier)
                          .useMeting();
                      Navigator.of(context).pop();
                    },
            ),
            for (final BiliSubtitleTrack track in state.tracks)
              ListTile(
                title: Text(track.label),
                subtitle: Text(track.language),
                selected: isCurrent && state.selectedTrackId == track.id,
                trailing: state.pendingTrackId == track.id
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : isCurrent && state.selectedTrackId == track.id
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : null,
                onTap: !isCurrent || state.pendingTrackId != null
                    ? null
                    : () async {
                        if (!_isCurrent(ref)) return;
                        final bool selected = await ref
                            .read(playerSubtitleControllerProvider.notifier)
                            .selectTrack(track.id);
                        if (!context.mounted) return;
                        if (selected && _isCurrent(ref)) {
                          Navigator.of(context).pop();
                        }
                      },
              ),
            if (isCurrent && state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
