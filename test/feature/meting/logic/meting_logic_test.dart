import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/logic/meting_logic.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetingLogic', () {
    test('find searches extracted title once', () async {
      final _FakeMetingRepository repository = _FakeMetingRepository(
        searchResponses: <String, List<MetingSearchItem>>{
          '晴天': <MetingSearchItem>[_item(title: '晴天', author: '周杰伦')],
        },
      );
      final MetingLogic logic = MetingLogic(repository: repository);

      final MetingSearchItem? result = await logic.find(title: '【LIVE】晴天');

      expect(result?.title, '晴天');
      expect(repository.queries, <String>['晴天']);
    });

    test('findLyrics returns null when no song is found', () async {
      final _FakeMetingRepository repository = _FakeMetingRepository();
      final MetingLogic logic = MetingLogic(repository: repository);

      final String? lyrics = await logic.findLyrics(title: '不存在的歌');

      expect(lyrics, isNull);
      expect(repository.lyricsItems, isEmpty);
    });

    test('findLyrics fetches lyrics for first search result', () async {
      final MetingSearchItem item = _item(title: '夜曲', author: '周杰伦');
      final _FakeMetingRepository repository = _FakeMetingRepository(
        searchResponses: <String, List<MetingSearchItem>>{
          '夜曲': <MetingSearchItem>[item],
        },
        lyricsResponses: <MetingSearchItem, String>{item: '[00:00.000] 夜曲'},
      );
      final MetingLogic logic = MetingLogic(repository: repository);

      final String? lyrics = await logic.findLyrics(
        title: '夜曲',
        server: MetingServer.tencent,
      );

      expect(lyrics, '[00:00.000] 夜曲');
      expect(repository.queries, <String>['夜曲']);
      expect(repository.lyricsItems, <MetingSearchItem>[item]);
    });
  });
}

MetingSearchItem _item({required String title, required String author}) {
  return MetingSearchItem(
    title: title,
    author: author,
    url: '',
    pic: '',
    lrc: 'https://meting.example/api?type=lrc',
  );
}

class _FakeMetingRepository extends MetingRepository {
  _FakeMetingRepository({
    Map<String, List<MetingSearchItem>>? searchResponses,
    Map<MetingSearchItem, String>? lyricsResponses,
  }) : _searchResponses = searchResponses ?? <String, List<MetingSearchItem>>{},
       _lyricsResponses = lyricsResponses ?? <MetingSearchItem, String>{},
       super(Dio());

  final Map<String, List<MetingSearchItem>> _searchResponses;
  final Map<MetingSearchItem, String> _lyricsResponses;
  final List<String> queries = <String>[];
  final List<MetingSearchItem> lyricsItems = <MetingSearchItem>[];

  @override
  Future<List<MetingSearchItem>> search({
    required String keyword,
    MetingServer server = MetingServer.netease,
  }) async {
    queries.add(keyword);
    return _searchResponses[keyword] ?? const <MetingSearchItem>[];
  }

  @override
  Future<String> fetchLyrics(MetingSearchItem item) async {
    lyricsItems.add(item);
    return _lyricsResponses[item] ?? '';
  }
}
