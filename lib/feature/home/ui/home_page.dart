import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/feature/home/ui/components/music_ranking_section.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppLayoutScope.of(context) == AppLayout.desktop
          ? null
          : AppBar(
              toolbarHeight: 48,
              title: CommonSearchBar(
                onTap: () => context.push('/search?from=/home'),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(musicRankingControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppLayoutScope.of(context) == AppLayout.desktop
              ? const EdgeInsets.symmetric(horizontal: 0)
              : const EdgeInsets.fromLTRB(16, 20, 16, 0),
          children: <Widget>[
            const RecentPlaybackSection(),
            const SizedBox(height: 30),
            const MusicRankingSection(),
            const BottomPageSpacer(),
          ],
        ),
      ),
    );
  }
}
