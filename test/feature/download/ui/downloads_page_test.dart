import 'dart:io';

import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/ui/downloads_page.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the empty state when nothing is downloaded', (
    WidgetTester tester,
  ) async {
    final Directory? directory = await tester.runAsync(
      () => Directory.systemTemp.createTemp('dl_'),
    );
    addTearDown(() async {
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final ProviderContainer container = ProviderContainer(
      overrides: [
        downloadRepositoryProvider.overrideWithValue(
          DownloadRepository(
            _MemoryIndexStore(),
            readDirectory: () async => directory!,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DownloadsPage()),
      ),
    );
    await tester.pump();

    expect(find.text('还没有下载的歌曲'), findsOneWidget);
  });

  testWidgets('lists downloaded tracks', (WidgetTester tester) async {
    final Directory? directory = await tester.runAsync(
      () => Directory.systemTemp.createTemp('dl_'),
    );
    addTearDown(() async {
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final _MemoryIndexStore store = _MemoryIndexStore();
    final DownloadRepository repository = DownloadRepository(
      store,
      readDirectory: () async => directory!,
      fetcher:
          ({
            required String url,
            required Map<String, String> headers,
            void Function(int, int)? onProgress,
          }) async => <int>[1, 2, 3, 4],
    );
    await tester.runAsync(() async {
      await repository.downloadTrack(
        item: const PlayableItem(
          aid: 1,
          bvid: 'BV1',
          cid: 10,
          page: 1,
          title: '夜曲',
          author: '周杰伦',
          coverUrl: '',
        ),
        stream: const AudioStreamInfo(
          streamUrl: 'https://example.com/audio.m4a',
          backupUrls: <String>[],
          headers: <String, String>{},
          cid: 10,
          duration: Duration(seconds: 225),
          bandwidth: 192000,
          availableQualities: <AudioQualityOption>[],
          qualityId: 30280,
          qualityLabel: '192K',
        ),
      );
    });
    final ProviderContainer container = ProviderContainer(
      overrides: [downloadRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DownloadsPage()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('已下载'), findsNothing);
    expect(find.text('夜曲'), findsOneWidget);
    expect(find.textContaining('周杰伦'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });
}

class _MemoryIndexStore implements DownloadIndexStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Map<String, String> loadAll() => Map<String, String>.of(_values);

  @override
  Future<void> put(String contentId, String json) async {
    _values[contentId] = json;
  }

  @override
  Future<void> remove(String contentId) async {
    _values.remove(contentId);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }
}
