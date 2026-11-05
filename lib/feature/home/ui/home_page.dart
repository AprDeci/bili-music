import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/music_chart_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PlatformUtil.isDesktop
          ? null
          : AppBar(
              toolbarHeight: 48,
              title: CommonSearchBar(
                onTap: () => context.push('/search?from=/home'),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(musicChartControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: PlatformUtil.isDesktop
              ? const EdgeInsets.symmetric(horizontal: 0)
              : const EdgeInsets.fromLTRB(16, 20, 16, 0),
          children: const <Widget>[MusicChartSection(), BottomPageSpacer()],
        ),
      ),
    );
  }
}
