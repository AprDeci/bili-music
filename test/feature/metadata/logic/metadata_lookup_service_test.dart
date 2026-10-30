import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetadataLookupService', () {
    test('returns resolved metadata when a lyric match is found', () async {
      final MetadataLookupService service = _service(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              return jsonEncode(<Map<String, dynamic>>[
                <String, dynamic>{
                  'id': '186016',
                  'name': '晴天',
                  'artist': <String>['周杰伦'],
                  'lyric_id': '186016',
                  'pic_id': '109951170473693123',
                },
              ]);
            },
        lyricRequest:
            ({required MetingServer server, required String id}) async {
              return jsonEncode(<String, dynamic>{
                'lyric': '[00:00.000] 歌词第一行',
              });
            },
        pictureRequest:
            ({
              required MetingServer server,
              required String id,
              required int size,
            }) async {
              return jsonEncode(<String, dynamic>{
                'url': 'https://img.example.com/cover.jpg',
              });
            },
      );

      final MetadataLookupResult result = await service.lookup(
        item: _item(),
        title: '晴天',
      );

      expect(result.metadata.hasContent, isTrue);
      expect(result.metadata.title, '晴天');
      expect(result.metadata.artist, '周杰伦');
      expect(result.metadata.albumArtUrl, 'https://img.example.com/cover.jpg');
      expect(result.metadata.hasLyrics, isTrue);
    });

    test('returns an empty metadata when no lyric match is found', () async {
      final MetadataLookupService service = _service(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              return jsonEncode(<Map<String, dynamic>>[]);
            },
      );

      final MetadataLookupResult result = await service.lookup(
        item: _item(),
        title: '不存在的歌',
      );

      expect(result.metadata.hasContent, isFalse);
    });

    test('inactive search does not start lyrics or picture fetches', () async {
      final pending = Completer<Object?>();
      int lyricCalls = 0;
      final service = _service(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) => pending.future,
        lyricRequest:
            ({required MetingServer server, required String id}) async {
              lyricCalls++;
              return jsonEncode({'lyric': '[00:00]Music'});
            },
      );
      bool active = true;
      final result = service.lookup(
        item: _item(),
        title: 'title',
        isActive: () => active,
      );
      final assertion = expectLater(result, throwsStateError);
      await Future<void>.delayed(Duration.zero);
      active = false;
      pending.complete(
        jsonEncode([
          {
            'id': 'song',
            'name': 'Music',
            'artist': ['Artist'],
            'lyric_id': 'song',
          },
        ]),
      );
      await assertion;
      expect(lyricCalls, 0);
    });

    test('inactive manual lyrics cannot start an artwork fetch', () async {
      final pending = Completer<Object?>();
      int pictureCalls = 0;
      final service = _service(
        searchRequest: _unusedSearchRequest,
        lyricRequest: ({required MetingServer server, required String id}) =>
            pending.future,
        pictureRequest:
            ({
              required MetingServer server,
              required String id,
              required int size,
            }) async {
              pictureCalls++;
              return null;
            },
      );
      bool active = true;
      final result = service.buildMetadataFromSearchItem(
        item: _item(),
        searchItem: const MetingSearchItem(
          id: 'song',
          title: 'Music',
          author: 'Artist',
          server: MetingServer.netease,
        ),
        isActive: () => active,
      );
      final assertion = expectLater(result, throwsStateError);
      active = false;
      pending.complete(jsonEncode({'lyric': '[00:00]Music'}));
      await assertion;
      expect(pictureCalls, 0);
    });

    test('extracts bracketed keyword before falling back', () async {
      final MetadataLookupService service = _service(
        searchRequest: _unusedSearchRequest,
      );

      expect(service.extractSearchKeyword('【MV】晴天'), '晴天');
      expect(service.extractSearchKeyword('《起风了》'), '起风了');
      expect(await service.resolveSearchKeyword('晴天'), '晴天');
    });
  });
}

PlayableItem _item() {
  return const PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: '视频标题',
    author: 'UP主',
    coverUrl: 'https://img.example.com/video.jpg',
    page: 1,
  );
}

MetadataLookupService _service({
  required MetingSearchRequest searchRequest,
  MetingLyricRequest? lyricRequest,
  MetingPictureRequest? pictureRequest,
}) {
  return MetadataLookupService(
    metingRepository: MetingRepository(
      searchRequest: searchRequest,
      lyricRequest: lyricRequest ?? _unusedLyricRequest,
      pictureRequest: pictureRequest ?? _unusedPictureRequest,
    ),
    resolveServer: (_) => MetingServer.netease,
  );
}

Future<Object?> _unusedSearchRequest({
  required MetingServer server,
  required String keyword,
  required Map<String, dynamic> option,
}) async {
  return jsonEncode(<Map<String, dynamic>>[]);
}

Future<Object?> _unusedLyricRequest({
  required MetingServer server,
  required String id,
}) {
  throw StateError('Unexpected lyric request');
}

Future<Object?> _unusedPictureRequest({
  required MetingServer server,
  required String id,
  required int size,
}) {
  throw StateError('Unexpected picture request');
}
