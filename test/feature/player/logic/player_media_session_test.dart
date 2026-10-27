import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Video title',
  author: 'Video UP',
  coverUrl: 'https://example.com/video.jpg',
);
final PlayableItem _nextItem = _item.copyWith(bvid: 'BV2xx411c7mD');
final Metadata _metadata = Metadata(
  stableId: _item.stableId,
  title: 'Song title',
  artist: 'Artist',
  albumArtUrl: 'https://example.com/album.jpg',
);
const AudioStreamInfo _stream = AudioStreamInfo(
  streamUrl: 'https://example.com/audio.m4a',
  backupUrls: <String>[],
  headers: <String, String>{},
  cid: 1,
  duration: Duration(minutes: 3),
  bandwidth: 192000,
  availableQualities: <AudioQualityOption>[],
  pageTitle: 'Part title',
  qualityLabel: '192K',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both media mappings follow the selected information source', () {
    for (final bool useMetadata in <bool>[true, false]) {
      final List<MediaItem> items = <MediaItem>[
        buildPlayerQueueMediaItem(
          _item,
          queueSourceLabel: 'Favorites',
          metadata: _metadata,
          useMetadata: useMetadata,
        ),
        buildPlayerMediaItem(
          _item,
          audioStream: _stream,
          queueSourceLabel: 'Favorites',
          metadata: _metadata,
          useMetadata: useMetadata,
        ),
      ];
      for (final MediaItem item in items) {
        expect(item.id, _item.stableId);
        expect(item.title, useMetadata ? _metadata.title : _item.title);
        expect(item.artist, useMetadata ? _metadata.artist : _item.author);
        expect(item.displayTitle, item.title);
        expect(item.displaySubtitle, item.artist);
        expect(
          item.artUri.toString(),
          useMetadata ? _metadata.albumArtUrl : _item.coverUrl,
        );
        expect(item.album, 'Favorites');
      }
      expect(items.last.duration, _stream.duration);
      expect(items.last.displayDescription, 'Part title · 192K');
    }
  });

  test('media mapping ignores another track metadata and keeps duration', () {
    final MediaItem item = buildPlayerMediaItem(
      _nextItem,
      audioStream: _stream,
      queueSourceLabel: null,
      duration: const Duration(seconds: 90),
      metadata: _metadata,
    );
    expect(item.title, _nextItem.title);
    expect(item.artist, _nextItem.author);
    expect(item.artUri.toString(), _nextItem.coverUrl);
    expect(item.duration, const Duration(seconds: 90));
    expect(item.album, 'Bilibili');
  });

  test(
    'paused session and current queue entry update without changing playback',
    () async {
      final AppAudioHandler handler = AppAudioHandler();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appAudioHandlerProvider.overrideWithValue(handler),
          playerControllerProvider.overrideWith(_SessionPlayerController.new),
          playerQueueLocalRepositoryProvider.overrideWithValue(
            _MemoryQueueRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final PlayerController controller = container.read(
        playerControllerProvider.notifier,
      );
      final PlayerState initialState = container.read(playerControllerProvider);

      controller.updateDisplayMetadata(metadata: _metadata, useMetadata: true);
      expect(handler.mediaItem.value?.title, _metadata.title);
      expect(handler.mediaItem.value?.artist, _metadata.artist);
      expect(handler.mediaItem.value?.artUri.toString(), _metadata.albumArtUrl);
      expect(handler.queue.value.first.title, _metadata.title);
      expect(handler.queue.value.last.title, _nextItem.title);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.updatePosition, initialState.position);
      expect(container.read(playerControllerProvider), initialState);

      controller.setQueueMode(PlayerQueueMode.singleRepeat);
      expect(handler.mediaItem.value?.title, _metadata.title);
      expect(handler.mediaItem.value?.artist, _metadata.artist);

      controller.updateDisplayMetadata(metadata: _metadata, useMetadata: false);
      expect(handler.mediaItem.value?.title, _item.title);
      expect(handler.mediaItem.value?.artist, _item.author);
      expect(handler.mediaItem.value?.artUri.toString(), _item.coverUrl);
      expect(handler.queue.value.first.title, _item.title);

      controller.setQueueMode(PlayerQueueMode.sequence);
      expect(handler.mediaItem.value?.title, _item.title);
      expect(handler.mediaItem.value?.artist, _item.author);

      controller.updateDisplayMetadata(
        metadata: _metadata.copyWith(title: 'Manual match'),
        useMetadata: true,
      );
      expect(handler.mediaItem.value?.title, 'Manual match');
      await Future<void>.value();
    },
  );

  test(
    'loading session publishes matched information before stream resolution',
    () {
      final AppAudioHandler handler = AppAudioHandler();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appAudioHandlerProvider.overrideWithValue(handler),
          playerControllerProvider.overrideWith(
            () => _SessionPlayerController(hasStream: false),
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(playerControllerProvider.notifier)
          .updateDisplayMetadata(metadata: _metadata, useMetadata: true);
      expect(handler.mediaItem.value?.title, _metadata.title);
      expect(handler.mediaItem.value?.displaySubtitle, _metadata.artist);
      expect(handler.mediaItem.value?.duration, const Duration(minutes: 3));
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.loading,
      );
    },
  );
}

class _SessionPlayerController extends PlayerController {
  _SessionPlayerController({this.hasStream = true});

  final bool hasStream;

  @override
  PlayerState build() => PlayerState(
    currentItem: _item,
    audioStream: hasStream ? _stream : null,
    queue: <PlayableItem>[_item, _nextItem],
    currentQueueIndex: 0,
    queueSourceLabel: 'Favorites',
    isReady: hasStream,
    isLoading: !hasStream,
    position: const Duration(seconds: 42),
    duration: const Duration(minutes: 3),
  );
}

class _MemoryQueueRepository implements PlayerQueueLocalRepository {
  @override
  PersistedPlaybackQueue? load() => null;

  @override
  Future<void> save(PersistedPlaybackQueue snapshot) async {}

  @override
  Future<void> clear() async {}
}
