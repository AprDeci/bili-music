import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:bilimusic/feature/player/logic/player_media_session_sync.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Video title',
  author: 'Video UP',
  coverUrl: 'https://example.com/video.jpg',
);
final PlayableItem _nextItem = _item.copyWith(
  bvid: 'BV2xx411c7mD',
  title: 'Next video',
  author: 'Next UP',
);
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

PlayerState _playingItem({bool hasStream = true}) => PlayerState(
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both media mappings consume the selected unified display', () {
    for (final PlayerDisplaySource source in PlayerDisplaySource.values) {
      final PlayerDisplayInfo display = resolvePlayerDisplayInfo(
        item: _item,
        metadata: _metadata,
        source: source,
      );
      final List<MediaItem> items = <MediaItem>[
        buildPlayerQueueMediaItem(
          _item,
          queueSourceLabel: 'Favorites',
          display: display,
        ),
        buildPlayerMediaItem(
          _item,
          audioStream: _stream,
          queueSourceLabel: 'Favorites',
          display: display,
        ),
      ];
      for (final MediaItem item in items) {
        expect(item.id, _item.stableId);
        expect(item.title, display.title);
        expect(item.artist, display.artist);
        expect(item.displayTitle, display.title);
        expect(item.displaySubtitle, display.artist);
        expect(item.artUri.toString(), display.coverUrl);
        expect(item.album, 'Favorites');
      }
      expect(items.last.duration, _stream.duration);
      expect(items.last.displayDescription, 'Part title · 192K');
    }
  });

  test('both mappings reject another track display and keep duration', () {
    final PlayerDisplayInfo staleDisplay = resolvePlayerDisplayInfo(
      item: _item,
      metadata: _metadata,
      source: PlayerDisplaySource.metadata,
    );
    for (final PlayerDisplayInfo? display in <PlayerDisplayInfo?>[
      null,
      staleDisplay,
    ]) {
      for (final MediaItem item in <MediaItem>[
        buildPlayerQueueMediaItem(
          _nextItem,
          queueSourceLabel: null,
          duration: const Duration(seconds: 90),
          display: display,
        ),
        buildPlayerMediaItem(
          _nextItem,
          audioStream: _stream,
          queueSourceLabel: null,
          duration: const Duration(seconds: 90),
          display: display,
        ),
      ]) {
        expect(item.title, _nextItem.title);
        expect(item.artist, _nextItem.author);
        expect(item.artUri.toString(), _nextItem.coverUrl);
        expect(item.duration, const Duration(seconds: 90));
        expect(item.album, 'Bilibili');
      }
    }
  });

  test(
    'playback snapshot uses the explicit index without republishing media',
    () async {
      final _CountingAudioHandler handler = _CountingAudioHandler();
      await handler.updateQueue(<MediaItem>[
        buildPlayerQueueMediaItem(_item, queueSourceLabel: null),
        buildPlayerQueueMediaItem(_nextItem, queueSourceLabel: null),
      ]);
      final MediaItem media = buildPlayerMediaItem(
        _item,
        audioStream: _stream,
        queueSourceLabel: null,
      );
      handler.updateCurrentMediaItem(media);

      for (final int? index in <int?>[1, null]) {
        handler.updatePlaybackSnapshot(
          isPlaying: false,
          isBuffering: false,
          hasPrevious: true,
          hasNext: true,
          position: const Duration(seconds: 42),
          bufferedPosition: const Duration(seconds: 60),
          queueIndex: index,
          speed: 1,
          processingState: AudioProcessingState.ready,
        );
        expect(handler.playbackState.value.queueIndex, index);
        expect(handler.mediaItem.value, same(media));
        expect(handler.mediaCalls, 1);
        expect(handler.queueCalls, 1);
      }
    },
  );

  test(
    'sync activated before playback follows real source toggles while paused',
    () async {
      final _SessionHarness session = _SessionHarness();
      addTearDown(session.container.dispose);
      expect(session.handler.mediaItem.value, isNull);

      session.metadata.show(_metadata);
      session.player.show(_playingItem());
      await session.container.pump();
      session.expectCurrent(
        _metadata.title!,
        _metadata.artist!,
        _metadata.albumArtUrl!,
      );
      expect(session.handler.queue.value.last.title, _nextItem.title);

      final PlaybackState paused = PlaybackState(
        playing: false,
        processingState: AudioProcessingState.ready,
        updatePosition: const Duration(seconds: 42),
        bufferedPosition: const Duration(seconds: 60),
        queueIndex: 0,
      );
      session.handler.playbackState.add(paused);
      final PlayerState playerState = session.container.read(
        playerControllerProvider,
      );
      session.container
          .read(playerDisplaySourceLogicProvider.notifier)
          .toggle();
      await session.container.pump();

      expect(
        session.container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.bilibili,
      );
      session.expectCurrent(_item.title, _item.author, _item.coverUrl);
      expect(session.handler.playbackState.value, same(paused));
      expect(
        session.container.read(playerControllerProvider),
        same(playerState),
      );

      session.container
          .read(playerDisplaySourceLogicProvider.notifier)
          .toggle();
      await session.container.pump();
      session.expectCurrent(
        _metadata.title!,
        _metadata.artist!,
        _metadata.albumArtUrl!,
      );
      expect(session.handler.playbackState.value, same(paused));
    },
  );

  test(
    'track and part changes reset source and reject stale metadata',
    () async {
      final _SessionHarness session = _SessionHarness();
      addTearDown(session.container.dispose);
      session.player.show(_playingItem());
      session.metadata.show(_metadata);
      await session.container.pump();
      session.container
          .read(playerDisplaySourceLogicProvider.notifier)
          .toggle();
      await session.container.pump();

      for (final PlayableItem next in <PlayableItem>[
        _nextItem,
        _nextItem.copyWith(cid: 123, page: 2, title: 'Next part'),
      ]) {
        session.player.show(
          _playingItem().copyWith(
            currentItem: next,
            queue: <PlayableItem>[_item, next],
            currentQueueIndex: 1,
          ),
        );
        await session.container.pump();
        expect(
          session.container.read(playerDisplaySourceLogicProvider),
          isNull,
        );
        session.expectCurrent(next.title, next.author, next.coverUrl);
        expect(session.handler.queue.value.first.title, _item.title);

        session.metadata.show(_metadata, stableId: next.stableId);
        await session.container.pump();
        session.expectCurrent(next.title, next.author, next.coverUrl);
        expect(
          session.container.read(playerDisplayProvider).canToggleSource,
          isFalse,
        );

        session.metadata.show(
          _metadata.copyWith(
            stableId: next.stableId,
            title: 'Next song',
            artist: 'Next artist',
          ),
        );
        await session.container.pump();
        session.expectCurrent(
          'Next song',
          'Next artist',
          _metadata.albumArtUrl!,
        );
        session.container
            .read(playerDisplaySourceLogicProvider.notifier)
            .toggle();
        await session.container.pump();
      }
    },
  );

  test(
    'late and manual metadata update loading media before a stream exists',
    () async {
      final _SessionHarness session = _SessionHarness();
      addTearDown(session.container.dispose);
      session.player.show(_playingItem(hasStream: false));
      await session.container.pump();
      session.expectCurrent(_item.title, _item.author, _item.coverUrl);
      expect(
        session.handler.mediaItem.value?.duration,
        const Duration(minutes: 3),
      );

      final PlaybackState loading = PlaybackState(
        processingState: AudioProcessingState.loading,
        playing: false,
      );
      session.handler.playbackState.add(loading);
      session.metadata.show(_metadata);
      await session.container.pump();
      session.expectCurrent(
        _metadata.title!,
        _metadata.artist!,
        _metadata.albumArtUrl!,
      );
      expect(session.handler.playbackState.value, same(loading));

      session.metadata.show(
        _metadata.copyWith(title: 'Manual match', artist: 'Manual artist'),
      );
      await session.container.pump();
      session.expectCurrent(
        'Manual match',
        'Manual artist',
        _metadata.albumArtUrl!,
      );
      expect(session.handler.playbackState.value, same(loading));

      session.player.show(_playingItem());
      await session.container.pump();
      expect(
        session.handler.mediaItem.value?.displayDescription,
        'Part title · 192K',
      );
      session.expectCurrent(
        'Manual match',
        'Manual artist',
        _metadata.albumArtUrl!,
      );
    },
  );

  test(
    'progress does not republish media, duration updates and clear removes it',
    () async {
      final _SessionHarness session = _SessionHarness();
      addTearDown(session.container.dispose);
      session.player.show(_playingItem());
      session.metadata.show(_metadata);
      await session.container.pump();
      final int queueCalls = session.handler.queueCalls;
      final int mediaCalls = session.handler.mediaCalls;

      for (int seconds = 43; seconds < 46; seconds++) {
        session.player.show(
          _playingItem().copyWith(
            position: Duration(seconds: seconds),
            bufferedPosition: Duration(seconds: seconds + 20),
          ),
        );
        await session.container.pump();
      }
      expect(session.handler.queueCalls, queueCalls);
      expect(session.handler.mediaCalls, mediaCalls);

      session.player.show(
        _playingItem().copyWith(duration: const Duration(seconds: 200)),
      );
      await session.container.pump();
      expect(
        session.handler.mediaItem.value?.duration,
        const Duration(seconds: 200),
      );
      expect(
        session.handler.queue.value.first.duration,
        const Duration(seconds: 200),
      );
      session.expectCurrent(
        _metadata.title!,
        _metadata.artist!,
        _metadata.albumArtUrl!,
      );

      session.player.show(const PlayerState());
      await session.container.pump();
      expect(session.handler.mediaItem.value, isNull);
      expect(session.handler.queue.value, isEmpty);
      expect(session.container.read(playerDisplayProvider).stableId, isNull);
    },
  );
}

class _SessionHarness {
  _SessionHarness() {
    container = ProviderContainer(
      overrides: [
        appAudioHandlerProvider.overrideWithValue(handler),
        playerControllerProvider.overrideWith(_SessionPlayerController.new),
        metadataControllerProvider.overrideWith(_SessionMetadataController.new),
        playerDisplaySettingsLogicProvider.overrideWithValue(true),
      ],
    );
    container.listen<void>(
      playerMediaSessionSyncProvider,
      (_, _) {},
      fireImmediately: true,
    );
  }

  final _CountingAudioHandler handler = _CountingAudioHandler();
  late final ProviderContainer container;

  _SessionPlayerController get player =>
      container.read(playerControllerProvider.notifier)
          as _SessionPlayerController;
  _SessionMetadataController get metadata =>
      container.read(metadataControllerProvider.notifier)
          as _SessionMetadataController;

  void expectCurrent(String title, String artist, String coverUrl) {
    final PlayerDisplayInfo display = container.read(playerDisplayProvider);
    final PlayerState state = container.read(playerControllerProvider);
    final MediaItem? current = handler.mediaItem.value;
    final MediaItem queueItem = handler.queue.value[state.currentQueueIndex!];
    expect(current?.id, display.stableId);
    expect(display.title, title);
    expect(display.artist, artist);
    expect(display.coverUrl, coverUrl);
    for (final MediaItem? item in <MediaItem?>[current, queueItem]) {
      expect(item?.title, title);
      expect(item?.artist, artist);
      expect(item?.artUri.toString(), coverUrl);
    }
  }
}

class _SessionPlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState();

  void show(PlayerState value) => state = value;
}

class _SessionMetadataController extends MetadataController {
  @override
  MetadataState build() => const MetadataState();

  void show(Metadata value, {String? stableId}) {
    state = MetadataState(
      stableId: stableId ?? value.stableId,
      metadata: value,
      hasSearched: true,
    );
  }
}

class _CountingAudioHandler extends AppAudioHandler {
  int queueCalls = 0;
  int mediaCalls = 0;

  @override
  Future<void> updateQueue(List<MediaItem> items) {
    queueCalls++;
    return super.updateQueue(items);
  }

  @override
  void updateCurrentMediaItem(MediaItem? item) {
    mediaCalls++;
    super.updateCurrentMediaItem(item);
  }
}
