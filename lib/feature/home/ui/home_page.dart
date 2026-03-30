import 'package:bilimusic/feature/home/ui/components/music_ranking_section.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: const <Widget>[MusicRankingSection()],
      ),
    );
  }
}
