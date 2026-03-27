import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class PlayerMainPage extends StatelessWidget {
  const PlayerMainPage({
    super.key,
    required this.state,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onSeek,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 4),
        SizedBox(
          width: 200,
          height: 200,
          child: PlayerArtworkFrame(coverUrl: item?.coverUrl ?? ''),
        ),
        const SizedBox(height: 28),
        PlayerTrackHeader(
          title: item?.title ?? '还没有选择播放内容',
          subtitle: item == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : buildPlayerSubtitle(item!.author, state),
          isFavoriteEnabled: item != null,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
        const SizedBox(height: 8),
        SwipeHint(label: state.currentItem == null ? '左右滑动切换页面' : '右滑回到播放页'),
        const SizedBox(height: 18),
        PlayerProgressSection(state: state, onChanged: onSeek),
        const SizedBox(height: 30),
        PlayerTransportControls(
          state: state,
          onBackward: onBackward,
          onTogglePlayback: onTogglePlayback,
          onForward: onForward,
        ),
        const SizedBox(height: 30),
        PlayerPlaybackStatusChip(state: state),
        const SizedBox(height: 18),
      ],
    );
  }
}
