import 'dart:async';

import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('player keeps cover extraction alive until the color arrives', () async {
    final Completer<Color?> extraction = Completer<Color?>();
    bool disposed = false;
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(stableId: 'song', coverUrl: 'cover'),
        ),
        playerArtworkColorProvider('cover').overrideWith((Ref ref) {
          ref.onDispose(() => disposed = true);
          return extraction.future;
        }),
      ],
    );
    addTearDown(container.dispose);
    container.listen(playerCoverColorControllerProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    await container.pump();

    expect(disposed, isFalse);
    extraction.complete(Colors.orange);
    await container.pump();
    expect(container.read(playerCoverColorControllerProvider), Colors.orange);

    final subscription = container.listen(
      playerArtworkColorProvider('cover'),
      (_, _) {},
    );
    expect(subscription.read().asData?.value, Colors.orange);
    subscription.close();
    await container.pump();
    expect(container.read(playerCoverColorControllerProvider), Colors.orange);
  });

  test(
    'cover changes release old extraction and ignore stale colors',
    () async {
      String coverUrl = 'first';
      final Map<String, Completer<Color?>> extractions = {
        for (final String url in ['first', 'second', 'third'])
          url: Completer<Color?>(),
      };
      final Set<String> disposed = <String>{};
      final ProviderContainer container = ProviderContainer(
        overrides: [
          playerDisplayProvider.overrideWith(
            (Ref ref) =>
                PlayerDisplayInfo(stableId: 'song', coverUrl: coverUrl),
          ),
          for (final entry in extractions.entries)
            playerArtworkColorProvider(entry.key).overrideWith((Ref ref) {
              ref.onDispose(() => disposed.add(entry.key));
              return entry.value.future;
            }),
        ],
      );
      addTearDown(container.dispose);
      container.listen(playerCoverColorControllerProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      extractions['first']!.complete(Colors.orange);
      await container.pump();
      expect(container.read(playerCoverColorControllerProvider), Colors.orange);

      Future<void> showCover(String url) async {
        coverUrl = url;
        container.invalidate(playerDisplayProvider);
        await container.pump();
        await Future<void>.delayed(Duration.zero);
        await container.pump();
      }

      await showCover('second');
      expect(disposed, contains('first'));
      expect(container.read(playerCoverColorControllerProvider), Colors.orange);
      await showCover('third');
      expect(disposed, contains('second'));
      extractions['third']!.complete(Colors.blue);
      await container.pump();
      extractions['second']!.complete(Colors.pink);
      await container.pump();
      expect(container.read(playerCoverColorControllerProvider), Colors.blue);

      await showCover('');
      expect(disposed, contains('third'));
      expect(container.read(playerCoverColorControllerProvider), isNull);
      expect(container.exists(playerArtworkColorProvider('')), isFalse);
    },
  );
}
