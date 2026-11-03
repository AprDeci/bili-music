import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarRecentPlaybackPage extends ConsumerWidget {
  const CarRecentPlaybackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlayableItem> items = ref
        .watch(recentPlaybackControllerProvider)
        .map((item) => item.toPlayableItem())
        .toList(growable: false);
    return Column(
      children: <Widget>[
        const CarContentHeader(title: '最近播放', backLocation: '/profile'),
        Expanded(
          child: CarSongList(
            items: items,
            sourceLabel: '最近播放',
            emptyTitle: '还没有最近播放',
            emptyDescription: '播放过的内容会按时间出现在这里。',
          ),
        ),
      ],
    );
  }
}
