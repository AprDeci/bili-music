import 'dart:convert';

import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:flutter_test/flutter_test.dart';

MusicChart _neteaseChart(int index) => MusicChartCatalog.neteaseCharts[index];

MusicChart _tencentChart(int index) => MusicChartCatalog.tencentCharts[index];

MusicChart _kugouChart(int index) => MusicChartCatalog.kugouCharts[index];

void main() {
  test('maps a meting playlist into ranked tracks', () async {
    final List<(MetingServer, String)> playlistCalls =
        <(MetingServer, String)>[];
    final MusicChartRepository repository = MusicChartRepository(
      playlistRequest: (MetingServer server, String chartId) async {
        playlistCalls.add((server, chartId));
        return jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'name': '晴天',
            'artist': <String>['周杰伦'],
            'pic_id': '109951170',
            'duration': 269000,
          },
          <String, dynamic>{
            'name': '晴天',
            'artist': <String>['周杰伦'],
            'pic_id': '109951170',
            'duration': 269000,
          },
          <String, dynamic>{
            'name': '七里香',
            'artist': <String>['周杰伦'],
            'pic_id': '109951171',
            'duration': 299000,
          },
        ]);
      },
      coverRequest: (MetingServer server, String pictureId) async {
        return 'https://p3.music.126.net/$pictureId.jpg';
      },
    );

    final List<MusicChartTrack> tracks = await repository.fetchTracks(
      _neteaseChart(0),
    );

    expect(tracks, hasLength(2));
    expect(tracks.first.title, '晴天');
    expect(tracks.first.artist, '周杰伦');
    expect(tracks.first.rank, 1);
    expect(tracks.first.durationSeconds, 269);
    expect(tracks.first.coverUrl, 'https://p3.music.126.net/109951170.jpg');
    expect(tracks.first.chart, _neteaseChart(0));
    expect(tracks.last.rank, 2);
    expect(playlistCalls.single, (MetingServer.netease, '3778678'));
  });

  test('caps the chart length and keeps the first occurrence', () async {
    final MusicChartRepository repository = MusicChartRepository(
      playlistRequest: (MetingServer server, String chartId) async {
        return <Map<String, dynamic>>[
          for (int index = 0; index < 40; index += 1)
            <String, dynamic>{
              'name': '歌曲 $index',
              'artist': <String>['歌手'],
              'duration': 200000,
            },
        ];
      },
      coverRequest: (MetingServer server, String pictureId) async => '',
    );

    final List<MusicChartTrack> tracks = await repository.fetchTracks(
      _neteaseChart(1),
    );

    expect(tracks, hasLength(MusicChartRepository.maxTrackCount));
    expect(tracks.first.rank, 1);
    expect(tracks.last.rank, MusicChartRepository.maxTrackCount);
  });

  test('reuses the cache for the same chart only', () async {
    final List<String> requestedChartIds = <String>[];
    final MusicChartRepository repository = MusicChartRepository(
      playlistRequest: (MetingServer server, String chartId) async {
        requestedChartIds.add(chartId);
        return <Map<String, dynamic>>[
          <String, dynamic>{
            'name': '晴天',
            'artist': <String>['周杰伦'],
          },
        ];
      },
      coverRequest: (MetingServer server, String pictureId) async => '',
    );

    await repository.fetchTracks(_neteaseChart(0));
    await repository.fetchTracks(_neteaseChart(0));
    await repository.fetchTracks(_neteaseChart(1));

    expect(requestedChartIds, <String>[
      _neteaseChart(0).chartId,
      _neteaseChart(1).chartId,
    ]);
  });

  test('parses the tencent toplist payload', () async {
    final List<String> topIds = <String>[];
    final MusicChart chart = _tencentChart(0);
    final MusicChartRepository repository = MusicChartRepository(
      toplistRequest: (String topId) async {
        topIds.add(topId);
        return jsonEncode(<String, dynamic>{
          'code': 0,
          'songlist': <Map<String, dynamic>>[
            <String, dynamic>{
              'data': <String, dynamic>{
                'songname': '晴天',
                'singer': <Map<String, dynamic>>[
                  <String, dynamic>{'name': '周杰伦'},
                ],
                'albummid': '003h24VO1pTh6K',
                'interval': 269,
              },
            },
            <String, dynamic>{
              'data': <String, dynamic>{
                'songname': '七里香',
                'singer': <Map<String, dynamic>>[
                  <String, dynamic>{'name': '周杰伦'},
                  <String, dynamic>{'name': '杨瑞代'},
                ],
                'albummid': '',
                'interval': 299,
              },
            },
            <String, dynamic>{
              'data': <String, dynamic>{
                'songname': '',
                'singer': <Map<String, dynamic>>[],
              },
            },
          ],
        });
      },
    );

    final List<MusicChartTrack> tracks = await repository.fetchTracks(chart);

    expect(topIds.single, chart.chartId);
    expect(tracks, hasLength(2));
    expect(tracks.first.rank, 1);
    expect(tracks.first.title, '晴天');
    expect(tracks.first.artist, '周杰伦');
    expect(tracks.first.durationSeconds, 269);
    expect(
      tracks.first.coverUrl,
      'https://y.gtimg.cn/music/photo_new/T002R300x300M000003h24VO1pTh6K.jpg',
    );
    expect(tracks.last.artist, '周杰伦 / 杨瑞代');
    expect(tracks.last.coverUrl, isEmpty);
  });

  test('throws when the tencent toplist response is invalid', () {
    expect(
      () => MusicChartRepository.parseTencentToplist(<String, dynamic>{
        'code': 1,
      }, _tencentChart(2)),
      throwsA(isA<MusicChartException>()),
    );
  });

  test('parses the kugou rank payload', () {
    final List<MusicChartTrack> tracks = MusicChartRepository.parseKugouRank(
      jsonEncode(<String, dynamic>{
        'status': 1,
        'data': <String, dynamic>{
          'info': <Map<String, dynamic>>[
            <String, dynamic>{
              'songname': '晴天',
              'authors': <Map<String, dynamic>>[
                <String, dynamic>{'author_name': '周杰伦'},
              ],
              'duration': 269,
              'trans_param': <String, dynamic>{
                'union_cover':
                    'http://imge.kugou.com/stdmusic/{size}/2026/cover.jpg',
              },
            },
            <String, dynamic>{
              'songname': '七里香',
              'filename': '周杰伦 - 七里香',
              'duration': 299,
              'album_sizable_cover':
                  'http://imge.kugou.com/stdmusic/{size}/2026/other.jpg',
            },
          ],
        },
      }),
      _kugouChart(0),
    );

    expect(tracks, hasLength(2));
    expect(tracks.first.title, '晴天');
    expect(tracks.first.artist, '周杰伦');
    expect(tracks.first.durationSeconds, 269);
    expect(
      tracks.first.coverUrl,
      'http://imge.kugou.com/stdmusic/300/2026/cover.jpg',
    );
    expect(tracks.last.artist, '周杰伦');
    expect(tracks.last.coverUrl, contains('/300/'));
  });

  test('throws when the kugou rank response is invalid', () {
    expect(
      () => MusicChartRepository.parseKugouRank(<String, dynamic>{
        'status': 0,
      }, _kugouChart(1)),
      throwsA(isA<MusicChartException>()),
    );
  });
}
