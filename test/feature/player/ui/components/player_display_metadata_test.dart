import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1xx411c7mD',
    title: 'Video title',
    author: 'Video UP',
    ownerMid: 123,
    coverUrl: 'https://example.com/video.jpg',
  );
  final Metadata metadata = Metadata(
    stableId: item.stableId,
    title: ' Song title ',
    artist: ' Artist ',
    albumArtUrl: ' https://example.com/album.jpg ',
  );

  PlayerDisplayInfo display(
    Metadata? value, {
    PlayableItem? currentItem = item,
    PlayerDisplaySource source = PlayerDisplaySource.metadata,
  }) => resolvePlayerDisplayInfo(
    item: currentItem,
    metadata: value,
    source: source,
  );

  test('display model has nullable fields and metadata defaults', () {
    expect(const PlayerDisplayInfo().source, PlayerDisplaySource.metadata);
    expect(const PlayerDisplayInfo().canToggleSource, isFalse);
    expect(const PlayerDisplayInfo().stableId, isNull);
    expect(const PlayerDisplayInfo().artistUpMid, isNull);
  });

  test('switches title artist and cover together with artist navigation', () {
    final PlayerDisplayInfo matched = display(metadata);
    expect(matched.stableId, item.stableId);
    expect(matched.title, 'Song title');
    expect(matched.artist, 'Artist');
    expect(matched.coverUrl, 'https://example.com/album.jpg');
    expect(matched.source, PlayerDisplaySource.metadata);
    expect(matched.canToggleSource, isTrue);
    expect(matched.artistUpMid, isNull);

    final PlayerDisplayInfo original = display(
      metadata,
      source: PlayerDisplaySource.bilibili,
    );
    expect(original.title, item.title);
    expect(original.artist, item.author);
    expect(original.coverUrl, item.coverUrl);
    expect(original.source, PlayerDisplaySource.bilibili);
    expect(original.canToggleSource, isTrue);
    expect(original.artistUpMid, item.ownerMid);
  });

  test('falls back independently for empty and missing metadata fields', () {
    final PlayerDisplayInfo artistOnly = display(
      metadata.copyWith(title: '  ', albumArtUrl: null),
    );
    expect(artistOnly.title, item.title);
    expect(artistOnly.artist, 'Artist');
    expect(artistOnly.coverUrl, item.coverUrl);
    expect(artistOnly.artistUpMid, isNull);

    final PlayerDisplayInfo titleOnly = display(
      metadata.copyWith(artist: '  ', albumArtUrl: ''),
    );
    expect(titleOnly.title, 'Song title');
    expect(titleOnly.artist, item.author);
    expect(titleOnly.coverUrl, item.coverUrl);
    expect(titleOnly.canToggleSource, isTrue);
    expect(titleOnly.artistUpMid, item.ownerMid);
  });

  test('unavailable and lyric-only metadata cannot toggle display', () {
    for (final Metadata? value in <Metadata?>[
      null,
      Metadata(stableId: item.stableId, lyrics: '[00:00]lyric'),
      Metadata(
        stableId: item.stableId,
        title: ' ',
        artist: ' ',
        albumArtUrl: ' ',
      ),
    ]) {
      final PlayerDisplayInfo result = display(value);
      expect(result.title, item.title);
      expect(result.artist, item.author);
      expect(result.coverUrl, item.coverUrl);
      expect(result.canToggleSource, isFalse);
      expect(result.artistUpMid, item.ownerMid);
    }
  });

  test('rejects stale metadata after switching tracks or parts', () {
    for (final PlayableItem next in <PlayableItem>[
      item.copyWith(bvid: 'BV2xx411c7mD'),
      item.copyWith(cid: 123, page: 2),
    ]) {
      final PlayerDisplayInfo result = display(metadata, currentItem: next);
      expect(result.stableId, next.stableId);
      expect(result.title, next.title);
      expect(result.artist, next.author);
      expect(result.coverUrl, next.coverUrl);
      expect(result.canToggleSource, isFalse);
      expect(result.artistUpMid, next.ownerMid);
    }
  });

  test('empty item clears display and blank artwork is absent', () {
    final PlayerDisplayInfo empty = display(metadata, currentItem: null);
    expect(empty.stableId, isNull);
    expect(empty.title, isNull);
    expect(empty.artist, isNull);
    expect(empty.coverUrl, isNull);
    expect(empty.artistUpMid, isNull);
    expect(empty.canToggleSource, isFalse);
    expect(
      display(null, currentItem: item.copyWith(coverUrl: '  ')).coverUrl,
      isNull,
    );
  });
}
