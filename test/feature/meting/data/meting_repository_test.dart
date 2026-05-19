import 'dart:convert';

import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetingRepository', () {
    test('search returns empty list for empty keyword', () async {
      final MetingRepository repository = MetingRepository(
        searchRequest: _unusedSearchRequest,
        lyricRequest: _unusedLyricRequest,
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: '   ',
      );

      expect(items, isEmpty);
    });

    test('search parses formatted meting_dart response', () async {
      final List<_SearchRequest> requests = <_SearchRequest>[];
      final MetingRepository repository = MetingRepository(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              requests.add(
                _SearchRequest(
                  server: server,
                  keyword: keyword,
                  option: option,
                ),
              );
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
        lyricRequest: _unusedLyricRequest,
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: ' 晴天 ',
        server: MetingServer.kugou,
      );

      expect(items, hasLength(1));
      expect(items.single.id, '186016');
      expect(items.single.title, '晴天');
      expect(items.single.author, '周杰伦');
      expect(items.single.server, MetingServer.kugou);
      expect(items.single.picId, '109951170473693123');
      expect(requests.single.server, MetingServer.kugou);
      expect(requests.single.keyword, '晴天');
      expect(requests.single.option['limit'], 10);
    });

    test('search falls back to song id when lyric id is missing', () async {
      final MetingRepository repository = MetingRepository(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              return jsonEncode(<Map<String, dynamic>>[
                <String, dynamic>{'id': 'kg_hash', 'name': '歌曲'},
              ]);
            },
        lyricRequest: _unusedLyricRequest,
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: '歌曲',
        server: MetingServer.kugou,
      );

      expect(items.single.id, 'kg_hash');
      expect(items.single.server, MetingServer.kugou);
    });

    test('search falls back to empty strings for missing fields', () async {
      final MetingRepository repository = MetingRepository(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              return jsonEncode(<Map<String, dynamic>>[
                <String, dynamic>{'name': '歌曲'},
              ]);
            },
        lyricRequest: _unusedLyricRequest,
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: '歌曲',
      );

      expect(items.single.title, '歌曲');
      expect(items.single.author, isEmpty);
      expect(items.single.id, isEmpty);
      expect(items.single.server, MetingServer.netease);
    });

    test('search rejects malformed response', () async {
      final MetingRepository repository = MetingRepository(
        searchRequest:
            ({
              required MetingServer server,
              required String keyword,
              required Map<String, dynamic> option,
            }) async {
              return jsonEncode(<String, dynamic>{'bad': true});
            },
        lyricRequest: _unusedLyricRequest,
      );

      await expectLater(
        repository.search(keyword: '晴天'),
        throwsA(
          isA<MetingException>().having(
            (MetingException error) => error.message,
            'message',
            contains('搜索返回格式异常'),
          ),
        ),
      );
    });

    test('fetchLyrics returns formatted lyric fields', () async {
      const String lyrics = '[00:00.000] 歌词第一行';
      const String translation = '[00:00.000] translated';
      const String romanized = '[00:00.000] romanized';
      const String karaoke = '[0,1000](0,500)歌(500,500)词';
      const String karaokeTranslation = '[0,1000]逐字翻译';
      final List<_LyricRequest> requests = <_LyricRequest>[];
      final MetingRepository repository = MetingRepository(
        searchRequest: _unusedSearchRequest,
        lyricRequest:
            ({required MetingServer server, required String id}) async {
              requests.add(_LyricRequest(server: server, id: id));
              return jsonEncode(<String, dynamic>{
                'lyric': lyrics,
                'tlyric': translation,
                'rlyric': romanized,
                'klyric': karaoke,
                'ktlyric': karaokeTranslation,
              });
            },
      );

      final MetaLyrics result = await repository.fetchLyrics(
        const MetingSearchItem(
          id: 'kg_hash',
          title: '晴天',
          author: '周杰伦',
          server: MetingServer.kugou,
          picId: 'kg_pic',
        ),
      );

      expect(result.lyric, lyrics);
      expect(result.translatedLyric, translation);
      expect(result.romanizedLyric, romanized);
      expect(result.karaokeLyric, karaoke);
      expect(result.karaokeTranslatedLyric, karaokeTranslation);
      expect(result.preferredMainLyric, karaoke);
      expect(result.preferredTranslationLyric, karaokeTranslation);
      expect(requests.single.server, MetingServer.kugou);
      expect(requests.single.id, 'kg_hash');
    });

    test('fetchLyrics rejects empty lyric id', () async {
      final MetingRepository repository = MetingRepository(
        searchRequest: _unusedSearchRequest,
        lyricRequest: _unusedLyricRequest,
      );

      await expectLater(
        repository.fetchLyrics(
          const MetingSearchItem(
            id: '',
            title: '晴天',
            author: '周杰伦',
            server: MetingServer.netease,
            picId: '',
          ),
        ),
        throwsA(
          isA<MetingException>().having(
            (MetingException error) => error.message,
            'message',
            contains('没有歌词 ID'),
          ),
        ),
      );
    });

    test('fetchPicture uses song id for kugou', () async {
      final List<_PictureRequest> requests = <_PictureRequest>[];
      final MetingRepository repository = MetingRepository(
        searchRequest: _unusedSearchRequest,
        lyricRequest: _unusedLyricRequest,
        pictureRequest:
            ({
              required MetingServer server,
              required String id,
              required int size,
            }) async {
              requests.add(_PictureRequest(server: server, id: id, size: size));
              return jsonEncode(<String, dynamic>{
                'url': 'https://img.example.com/from-pic.jpg',
              });
            },
      );

      final String result = await repository.fetchPicture(
        const MetingSearchItem(
          id: 'kg_hash',
          title: '晴天',
          author: '周杰伦',
          server: MetingServer.kugou,
          picId: 'https://imge.kugou.com/stdmusic/{size}/cover.jpg',
        ),
        size: 480,
      );

      expect(result, 'https://img.example.com/from-pic.jpg');
      expect(requests.single.server, MetingServer.kugou);
      expect(requests.single.id, 'kg_hash');
      expect(requests.single.size, 480);
    });
  });
}

Future<Object?> _unusedSearchRequest({
  required MetingServer server,
  required String keyword,
  required Map<String, dynamic> option,
}) {
  throw StateError('Unexpected search request');
}

Future<Object?> _unusedLyricRequest({
  required MetingServer server,
  required String id,
}) {
  throw StateError('Unexpected lyric request');
}

class _SearchRequest {
  const _SearchRequest({
    required this.server,
    required this.keyword,
    required this.option,
  });

  final MetingServer server;
  final String keyword;
  final Map<String, dynamic> option;
}

class _LyricRequest {
  const _LyricRequest({required this.server, required this.id});

  final MetingServer server;
  final String id;
}

class _PictureRequest {
  const _PictureRequest({
    required this.server,
    required this.id,
    required this.size,
  });

  final MetingServer server;
  final String id;
  final int size;
}
