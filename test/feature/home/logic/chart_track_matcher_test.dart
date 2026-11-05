import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:flutter_test/flutter_test.dart';

const MusicChartTrack _track = MusicChartTrack(
  chart: MusicChartCatalog.defaultChart,
  rank: 1,
  title: '晴天',
  artist: '周杰伦',
  coverUrl: '',
  durationSeconds: 269,
);

SearchResultItem _item({
  String title = '',
  String author = '',
  String duration = '00:00',
}) {
  return SearchResultItem(
    aid: 1,
    bvid: 'BV1',
    typeId: 3,
    title: title,
    author: author,
    coverUrl: '',
    duration: duration,
    playCountText: '',
    danmakuCountText: '',
    publishTimeText: '',
    tagText: '',
  );
}

void main() {
  test('prefers the candidate containing title, artist and duration', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '无关视频', duration: '04:29'),
      _item(title: '【4K】晴天 - 周杰伦 现场版', duration: '04:30'),
      _item(title: '晴天', author: '翻唱', duration: '03:10'),
    ];

    final SearchResultItem? match = ChartTrackMatcher.pickBest(
      track: _track,
      candidates: candidates,
    );

    expect(match, isNotNull);
    expect(match!.title, contains('晴天 - 周杰伦'));
  });

  test('keeps the first candidate on ties', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '晴天', duration: '04:29'),
      _item(title: '晴天', duration: '04:29'),
    ];

    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: candidates)?.title,
      '晴天',
    );
  });

  test('returns null when nothing looks like the song', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '篮球集锦', duration: '10:00'),
      _item(title: '游戏实况', duration: '20:00'),
    ];

    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: candidates),
      isNull,
    );
    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: const []),
      isNull,
    );
  });

  test('rejects an artist-only title when the duration is far off', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: [_item(title: '周杰伦金曲串烧', duration: '10:00')],
      ),
      isNull,
    );
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: [_item(title: '周杰伦金曲串烧', duration: '04:31')],
      ),
      isNotNull,
    );
  });

  test('parses durations and normalizes text', () {
    expect(ChartTrackMatcher.parseDurationSeconds('04:29'), 269);
    expect(ChartTrackMatcher.parseDurationSeconds('1:02:03'), 3723);
    expect(ChartTrackMatcher.parseDurationSeconds(''), 0);
    expect(ChartTrackMatcher.parseDurationSeconds('abc'), 0);
    expect(ChartTrackMatcher.normalize('【4K】晴天 - 周杰伦'), '4k晴天周杰伦');
  });
}
