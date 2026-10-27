import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1xx411c7mD',
    title: 'Video title',
    author: 'Video UP',
    coverUrl: 'https://example.com/video.jpg',
  );
  final Metadata metadata = Metadata(
    stableId: item.stableId,
    title: ' Song title ',
    artist: ' Artist ',
    albumArtUrl: ' https://example.com/album.jpg ',
  );

  List<String?> display(
    Metadata? value, {
    PlayableItem? currentItem = item,
    bool useMetadata = true,
  }) => <String?>[
    resolveDisplayTitle(
      item: currentItem,
      metadata: value,
      useMetadata: useMetadata,
    ),
    resolveDisplayArtist(
      item: currentItem,
      metadata: value,
      useMetadata: useMetadata,
    ),
    resolveDisplayCoverUrl(
      item: currentItem,
      metadata: value,
      useMetadataCover: useMetadata,
    ),
  ];

  test('switches title artist and cover together', () {
    expect(display(metadata), <String>[
      'Song title',
      'Artist',
      'https://example.com/album.jpg',
    ]);
    expect(display(metadata, useMetadata: false), <String>[
      item.title,
      item.author,
      item.coverUrl,
    ]);
    expect(hasSwitchableDisplay(item: item, metadata: metadata), isTrue);
    expect(
      usesMetadataArtist(item: item, metadata: metadata, useMetadata: true),
      isTrue,
    );
    expect(
      usesMetadataArtist(item: item, metadata: metadata, useMetadata: false),
      isFalse,
    );
  });

  test('falls back independently for empty and missing fields', () {
    expect(display(metadata.copyWith(title: '  ', albumArtUrl: null)), <String>[
      item.title,
      'Artist',
      item.coverUrl,
    ]);
    final Metadata titleOnly = metadata.copyWith(artist: '  ', albumArtUrl: '');
    expect(display(titleOnly), <String>[
      'Song title',
      item.author,
      item.coverUrl,
    ]);
    expect(hasSwitchableDisplay(item: item, metadata: titleOnly), isTrue);
    expect(
      usesMetadataArtist(item: item, metadata: titleOnly, useMetadata: true),
      isFalse,
    );
  });

  test('uses Bilibili information while metadata is unavailable', () {
    expect(display(null), <String>[item.title, item.author, item.coverUrl]);
    expect(hasSwitchableDisplay(item: item, metadata: null), isFalse);
    expect(
      hasSwitchableDisplay(
        item: item,
        metadata: Metadata(stableId: item.stableId, lyrics: '[00:00]lyric'),
      ),
      isFalse,
    );
  });

  test('rejects stale metadata after switching tracks or parts', () {
    for (final PlayableItem next in <PlayableItem>[
      item.copyWith(bvid: 'BV2xx411c7mD'),
      item.copyWith(cid: 123, page: 2),
    ]) {
      expect(display(metadata, currentItem: next), <String>[
        next.title,
        next.author,
        next.coverUrl,
      ]);
      expect(hasSwitchableDisplay(item: next, metadata: metadata), isFalse);
      expect(
        usesMetadataArtist(item: next, metadata: metadata, useMetadata: true),
        isFalse,
      );
    }
  });

  test('does not display metadata without a current item', () {
    expect(display(metadata, currentItem: null), <String?>[null, null, null]);
    expect(hasSwitchableDisplay(item: null, metadata: metadata), isFalse);
  });
}
