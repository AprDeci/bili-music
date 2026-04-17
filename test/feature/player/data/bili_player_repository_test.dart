import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiliPlayerRepository', () {
    test('resolvePreferredPart enriches item from view response', () async {
      final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
        responses: <String, Map<String, dynamic>>{
          '/x/web-interface/view': _viewResponse(),
        },
      );
      final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

      final PlayableItem item = await repository.resolvePreferredPart(
        _baseItem(page: 2),
        preferredPage: 2,
      );

      expect(item.title, 'View Title');
      expect(item.author, 'Owner Name');
      expect(item.cid, 222);
      expect(item.page, 2);
      expect(item.pageTitle, 'Part 2');
      expect(item.description, 'View description');
      expect(item.playCountText, isNotEmpty);
      expect(item.replyCount, 1234);
      expect(item.publishTimeText, isNotNull);
      expect(apiClient.requests.single.path, '/x/web-interface/view');
      expect(apiClient.requests.single.queryParameters['bvid'], 'BVTEST123');
      expect(apiClient.requests.single.queryParameters['aid'], 1001);
    });

    test(
      'resolveAudioStream parses dash audio and selects auto highest',
      () async {
        final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
          responses: <String, Map<String, dynamic>>{
            '/x/web-interface/view': _viewResponse(),
            '/x/player/wbi/playurl': _playurlResponse(),
          },
        );
        final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

        final PlayerLoadResult result = await repository.resolveAudioStream(
          _baseItem(page: 2),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.auto,
        );

        expect(result.item.cid, 222);
        expect(result.item.pageTitle, 'Part 2');
        expect(result.availableParts, hasLength(2));
        expect(
          result.availableParts.map((PlayableItem item) => item.cid),
          <int?>[111, 222],
        );
        expect(result.audioStream.streamUrl, 'https://audio.example/192k.m4s');
        expect(result.audioStream.backupUrls, <String>[
          'https://backup.example/192k.m4s',
        ]);
        expect(result.audioStream.cid, 222);
        expect(result.audioStream.duration, const Duration(seconds: 185));
        expect(result.audioStream.qualityId, 30280);
        expect(result.audioStream.qualityLabel, '192K');
        expect(result.audioStream.headers['Cookie'], 'SESSDATA=test;');
        expect(
          result.audioStream.availableQualities.map(
            (AudioQualityOption option) => option.label,
          ),
          <String>['192K', '132K', '64K'],
        );
        expect(
          result.audioStream.availableQualities
              .singleWhere(
                (AudioQualityOption option) => option.qualityId == 30280,
              )
              .isSelected,
          isTrue,
        );

        final _Request playurlRequest = apiClient.requests.singleWhere(
          (_Request request) => request.path == '/x/player/wbi/playurl',
        );
        expect(playurlRequest.requiresWbi, isTrue);
        expect(playurlRequest.queryParameters['cid'], 222);
        expect(playurlRequest.queryParameters['fnval'], 4048);
        expect(playurlRequest.options?.headers?['Cookie'], 'SESSDATA=test;');
      },
    );

    test(
      'resolveAudioStream selects configured quality when available',
      () async {
        final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
          responses: <String, Map<String, dynamic>>{
            '/x/web-interface/view': _viewResponse(),
            '/x/player/wbi/playurl': _playurlResponse(),
          },
        );
        final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

        final PlayerLoadResult result = await repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.k132,
        );

        expect(result.audioStream.streamUrl, 'https://audio.example/132k.m4s');
        expect(result.audioStream.qualityId, 30232);
        expect(
          result.audioStream.availableQualities
              .singleWhere(
                (AudioQualityOption option) => option.qualityId == 30232,
              )
              .isSelected,
          isTrue,
        );
      },
    );

    test(
      'resolveAudioStream falls back to highest when configured quality is missing',
      () async {
        final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
          responses: <String, Map<String, dynamic>>{
            '/x/web-interface/view': _viewResponse(),
            '/x/player/wbi/playurl': _playurlResponse(
              audioEntries: <Map<String, dynamic>>[
                _audioEntry(id: 30280, bandwidth: 192000, url: '192k'),
                _audioEntry(id: 30216, bandwidth: 64000, url: '64k'),
              ],
            ),
          },
        );
        final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

        final PlayerLoadResult result = await repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.k132,
        );

        expect(result.audioStream.streamUrl, 'https://audio.example/192k.m4s');
        expect(result.audioStream.qualityId, 30280);
      },
    );

    test(
      'resolveAudioStream lets explicit quality override default preference',
      () async {
        final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
          responses: <String, Map<String, dynamic>>{
            '/x/web-interface/view': _viewResponse(),
            '/x/player/wbi/playurl': _playurlResponse(),
          },
        );
        final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

        final PlayerLoadResult result = await repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.auto,
          preferredQualityId: 30216,
        );

        expect(result.audioStream.streamUrl, 'https://audio.example/64k.m4s');
        expect(result.audioStream.qualityId, 30216);
      },
    );

    test(
      'resolveAudioStream includes flac candidate for Hi-Res preference',
      () async {
        final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
          responses: <String, Map<String, dynamic>>{
            '/x/web-interface/view': _viewResponse(),
            '/x/player/wbi/playurl': _playurlResponse(
              flacAudio: _audioEntry(
                id: 30251,
                bandwidth: 900000,
                url: 'hires',
              ),
            ),
          },
        );
        final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

        final PlayerLoadResult result = await repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.hires,
        );

        expect(result.audioStream.streamUrl, 'https://audio.example/hires.m4s');
        expect(result.audioStream.qualityId, 30251);
        expect(result.audioStream.qualityLabel, 'Hi-Res');
        expect(
          result.audioStream.availableQualities.map(
            (AudioQualityOption option) => option.label,
          ),
          contains('Hi-Res'),
        );
      },
    );

    test('resolveAudioStream rejects malformed view response', () async {
      final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
        responses: <String, Map<String, dynamic>>{
          '/x/web-interface/view': <String, dynamic>{'data': 'bad'},
        },
      );
      final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

      await expectLater(
        repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.auto,
        ),
        throwsA(isA<BiliPlayerException>()),
      );
    });

    test('resolveAudioStream rejects response without audio streams', () async {
      final _FakeBiliApiClient apiClient = _FakeBiliApiClient(
        responses: <String, Map<String, dynamic>>{
          '/x/web-interface/view': _viewResponse(),
          '/x/player/wbi/playurl': _playurlResponse(
            audioEntries: const <Map<String, dynamic>>[],
          ),
        },
      );
      final BiliPlayerRepository repository = BiliPlayerRepository(apiClient);

      await expectLater(
        repository.resolveAudioStream(
          _baseItem(),
          session: _session(),
          qualityPreference: PlayerAudioQualityPreference.auto,
        ),
        throwsA(
          isA<BiliPlayerException>().having(
            (BiliPlayerException error) => error.message,
            'message',
            contains('No audio stream'),
          ),
        ),
      );
    });
  });
}

PlayableItem _baseItem({int page = 1}) {
  return PlayableItem(
    aid: 1001,
    bvid: 'BVTEST123',
    cid: null,
    page: page,
    title: 'Original Title',
    author: 'Original Author',
    coverUrl: 'https://example.com/cover.jpg',
    durationText: '03:05',
  );
}

BiliSession _session() {
  return const BiliSession(
    sessData: 'test',
    biliJct: 'csrf',
    dedeUserId: '42',
    refreshToken: 'refresh',
    cookie: 'SESSDATA=test;',
    imgKey: 'img',
    subKey: 'sub',
  );
}

Map<String, dynamic> _viewResponse() {
  return <String, dynamic>{
    'data': <String, dynamic>{
      'title': 'View Title',
      'owner': <String, dynamic>{'name': 'Owner Name'},
      'desc': '  View description  ',
      'pubdate': 1700000000,
      'stat': <String, dynamic>{
        'view': 12345,
        'danmaku': 234,
        'like': 345,
        'coin': 45,
        'favorite': 56,
        'share': 67,
        'reply': 1234,
      },
      'pages': <Map<String, dynamic>>[
        <String, dynamic>{'cid': 111, 'page': 1, 'part': 'Part 1'},
        <String, dynamic>{'cid': 222, 'page': 2, 'part': 'Part 2'},
      ],
    },
  };
}

Map<String, dynamic> _playurlResponse({
  List<Map<String, dynamic>>? audioEntries,
  Map<String, dynamic>? flacAudio,
}) {
  return <String, dynamic>{
    'data': <String, dynamic>{
      'timelength': 185000,
      'dash': <String, dynamic>{
        'audio':
            audioEntries ??
            <Map<String, dynamic>>[
              _audioEntry(
                id: 30280,
                bandwidth: 192000,
                url: '192k',
                backupUrls: <String>['https://backup.example/192k.m4s'],
              ),
              _audioEntry(id: 30232, bandwidth: 132000, url: '132k'),
              _audioEntry(id: 30216, bandwidth: 64000, url: '64k'),
            ],
        if (flacAudio != null) 'flac': <String, dynamic>{'audio': flacAudio},
      },
    },
  };
}

Map<String, dynamic> _audioEntry({
  required int id,
  required int bandwidth,
  required String url,
  List<String> backupUrls = const <String>[],
}) {
  return <String, dynamic>{
    'id': id,
    'bandwidth': bandwidth,
    'baseUrl': 'https://audio.example/$url.m4s',
    'backupUrl': backupUrls,
  };
}

class _FakeBiliApiClient implements BiliApiClient {
  _FakeBiliApiClient({required this.responses});

  final Map<String, Map<String, dynamic>> responses;
  final List<_Request> requests = <_Request>[];

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    Options? options,
  }) async {
    requests.add(
      _Request(
        path: path,
        queryParameters: queryParameters ?? const <String, dynamic>{},
        requiresAuth: requiresAuth,
        requiresWbi: requiresWbi,
        options: options,
      ),
    );

    final Map<String, dynamic>? response = responses[path];
    if (response == null) {
      throw StateError('Unexpected request: $path');
    }
    return response;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request {
  const _Request({
    required this.path,
    required this.queryParameters,
    required this.requiresAuth,
    required this.requiresWbi,
    required this.options,
  });

  final String path;
  final Map<String, dynamic> queryParameters;
  final bool requiresAuth;
  final bool requiresWbi;
  final Options? options;
}
