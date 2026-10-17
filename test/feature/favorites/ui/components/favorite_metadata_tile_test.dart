import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_metadata_tile.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders metadata title and artist without lyric tag', (
    WidgetTester tester,
  ) async {
    await _pumpTile(
      tester,
      metadata: const Metadata(
        stableId: 'bvid:BV1:cid:1',
        title: '晴天',
        artist: '周杰伦',
        lyrics: '[00:00.000] 歌词',
      ),
    );

    expect(find.text('晴天'), findsOneWidget);
    expect(find.text('周杰伦'), findsOneWidget);
    expect(find.text('词'), findsNothing);
    expect(find.text('未解析'), findsNothing);
  });

  testWidgets('falls back to entry fields and marks unresolved', (
    WidgetTester tester,
  ) async {
    await _pumpTile(tester, metadata: null);

    expect(find.text('视频标题'), findsOneWidget);
    expect(find.text('UP主'), findsOneWidget);
    expect(find.text('未解析'), findsOneWidget);
  });

  testWidgets('play and more callbacks fire', (WidgetTester tester) async {
    int playCount = 0;
    int moreCount = 0;
    await _pumpTile(
      tester,
      metadata: null,
      onPlay: () => playCount++,
      onMore: () => moreCount++,
    );

    await tester.tap(find.byTooltip('播放'));
    await tester.tap(find.byTooltip('更多'));
    await tester.pump();

    expect(playCount, 1);
    expect(moreCount, 1);
  });
}

Future<void> _pumpTile(
  WidgetTester tester, {
  required Metadata? metadata,
  VoidCallback? onPlay,
  VoidCallback? onMore,
}) async {
  final FavoriteEntry entry = FavoriteEntry(
    itemId: 'bvid:BV1:cid:1',
    aid: 1,
    bvid: 'BV1',
    title: '视频标题',
    author: 'UP主',
    coverUrl: 'https://img.example.com/video.jpg',
    page: 1,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoriteEntryMetadataProvider(
          entry.contentId,
        ).overrideWith((ref) async => metadata),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FavoriteMetadataTile(
            entry: entry,
            selected: false,
            onTap: () {},
            onLongPress: () {},
            onPlay: onPlay ?? () {},
            onMore: onMore ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
