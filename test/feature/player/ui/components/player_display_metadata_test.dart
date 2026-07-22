import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_display_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1xx411c7mD',
    title: 'Test item',
    author: 'Author',
    coverUrl: 'https://example.com/video.jpg',
    durationText: '03:21',
    playCountText: '0',
    danmakuCountText: '0',
    likeCountText: '0',
    coinCountText: '0',
    favoriteCountText: '0',
    shareCountText: '0',
    replyCountText: '0',
    publishTimeText: '2026-01-01',
    description: '',
  );
  const Metadata metadata = Metadata(
    stableId: 'test-item',
    albumArtUrl: 'https://example.com/album.jpg',
  );

  test('resolves selected cover source', () {
    expect(
      resolveDisplayCoverUrl(
        item: item,
        metadata: metadata,
        useMetadataCover: true,
      ),
      metadata.albumArtUrl,
    );
    expect(
      resolveDisplayCoverUrl(
        item: item,
        metadata: metadata,
        useMetadataCover: false,
      ),
      item.coverUrl,
    );
    expect(hasSwitchableCover(item: item, metadata: metadata), isTrue);
  });
}
