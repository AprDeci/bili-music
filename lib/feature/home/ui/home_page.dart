import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/feature/home/ui/components/music_ranking_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(musicRankingControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: const <Widget>[MusicRankingSection()],
        ),
      ),
    );
  }
}
