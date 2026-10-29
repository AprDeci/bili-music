import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final FavoriteEntry _entry = FavoriteEntry(
  itemId: 'bvid:BV1:cid:1',
  aid: 1,
  bvid: 'BV1',
  cid: 1,
  title: 'Video',
  author: 'UP',
  coverUrl: 'https://example.com/video.jpg',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late ProviderContainer container;
  late Completer<Metadata?> metadata;
  late bool requestedMetadata;

  setUp(() {
    metadata = Completer<Metadata?>();
    requestedMetadata = false;
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        favoritesViewModeLogicProvider.overrideWith(_ViewMode.new),
        favoriteEntryMetadataProvider(_entry.contentId).overrideWith((ref) {
          requestedMetadata = true;
          return metadata.future;
        }),
      ],
    );
    container.listen(favoriteEntryCoverUrlProvider(_entry), (_, _) {});
  });

  tearDown(() => container.dispose());

  test(
    'cover follows view mode and late metadata without fetching in video mode',
    () async {
      final provider = favoriteEntryCoverUrlProvider(_entry);
      expect(container.read(provider), _entry.coverUrl);
      expect(requestedMetadata, isFalse);

      final _ViewMode mode =
          container.read(favoritesViewModeLogicProvider.notifier) as _ViewMode;
      await mode.setViewMode(FavoriteListViewMode.metadata);
      expect(container.read(provider), _entry.coverUrl);
      expect(requestedMetadata, isTrue);

      metadata.complete(
        Metadata(
          stableId: _entry.itemId,
          albumArtUrl: '  https://example.com/album.jpg  ',
        ),
      );
      await container.read(
        favoriteEntryMetadataProvider(_entry.contentId).future,
      );
      await container.pump();
      expect(container.read(provider), 'https://example.com/album.jpg');

      await mode.setViewMode(FavoriteListViewMode.video);
      expect(container.read(provider), _entry.coverUrl);
    },
  );

  for (final String? cover in <String?>[null, '', '   ']) {
    test('missing album cover ($cover) falls back to video', () async {
      await container
          .read(favoritesViewModeLogicProvider.notifier)
          .setViewMode(FavoriteListViewMode.metadata);
      container.read(favoriteEntryCoverUrlProvider(_entry));
      metadata.complete(
        cover == null
            ? null
            : Metadata(
                stableId: _entry.itemId,
                title: 'Song',
                albumArtUrl: cover,
              ),
      );
      await container.read(
        favoriteEntryMetadataProvider(_entry.contentId).future,
      );
      await container.pump();
      expect(
        container.read(favoriteEntryCoverUrlProvider(_entry)),
        _entry.coverUrl,
      );
    });
  }

  test('cache failure keeps the video cover', () async {
    await container
        .read(favoritesViewModeLogicProvider.notifier)
        .setViewMode(FavoriteListViewMode.metadata);
    container.read(favoriteEntryCoverUrlProvider(_entry));
    final Future<Metadata?> result = container.read(
      favoriteEntryMetadataProvider(_entry.contentId).future,
    );
    metadata.completeError(StateError('cache unavailable'));
    await expectLater(result, throwsStateError);
    await container.pump();
    expect(
      container.read(favoriteEntryCoverUrlProvider(_entry)),
      _entry.coverUrl,
    );
  });

  test('empty collection keeps its placeholder without reading metadata', () {
    expect(container.read(favoriteEntryCoverUrlProvider(null)), isNull);
    expect(requestedMetadata, isFalse);
  });
}

class _ViewMode extends FavoritesViewModeLogic {
  @override
  FavoriteListViewMode build() => FavoriteListViewMode.video;

  @override
  Future<void> setViewMode(FavoriteListViewMode mode) async {
    state = mode;
  }
}
