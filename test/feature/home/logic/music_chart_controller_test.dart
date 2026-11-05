import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MusicChartRepository _repository({
  List<String>? requestedCharts,
  bool fail = false,
}) {
  Future<void> record(String chartId) async {
    requestedCharts?.add(chartId);
    if (fail) {
      throw const MusicChartException('榜单加载失败');
    }
  }

  return MusicChartRepository(
    playlistRequest: (_, String chartId) async {
      await record(chartId);
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'name': '歌曲 $chartId',
          'artist': <String>['歌手'],
          'duration': 200000,
        },
      ];
    },
    coverRequest: (_, _) async => '',
    toplistRequest: (String topId) async {
      await record(topId);
      return <String, dynamic>{
        'code': 0,
        'songlist': <Map<String, dynamic>>[
          <String, dynamic>{
            'data': <String, dynamic>{
              'songname': '歌曲 $topId',
              'singer': <Map<String, dynamic>>[
                <String, dynamic>{'name': '歌手'},
              ],
              'interval': 200,
            },
          },
        ],
      };
    },
    rankSongRequest: (String rankId) async {
      await record(rankId);
      return <String, dynamic>{
        'status': 1,
        'data': <String, dynamic>{
          'info': <Map<String, dynamic>>[
            <String, dynamic>{
              'songname': '歌曲 $rankId',
              'authors': <Map<String, dynamic>>[
                <String, dynamic>{'author_name': '歌手'},
              ],
              'duration': 200,
            },
          ],
        },
      };
    },
  );
}

Future<MusicChartState> _settle(ProviderContainer container) async {
  for (int attempt = 0; attempt < 100; attempt += 1) {
    final MusicChartState state = container.read(musicChartControllerProvider);
    if (!state.isLoading) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return container.read(musicChartControllerProvider);
}

Future<MusicChartState> _start(ProviderContainer container) async {
  container.read(musicChartControllerProvider.notifier);
  return _settle(container);
}

ProviderContainer _container(MusicChartRepository repository) {
  final ProviderContainer container = ProviderContainer(
    overrides: [musicChartRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('loads the default chart', () async {
    final List<String> requestedCharts = <String>[];
    final ProviderContainer container = _container(
      _repository(requestedCharts: requestedCharts),
    );

    final MusicChartState state = await _start(container);

    expect(state.chart, MusicChartCatalog.defaultChart);
    expect(state.platform, MusicChartPlatform.netease);
    expect(state.tracks.single.title, '歌曲 ${state.chart.chartId}');
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(requestedCharts.last, state.chart.chartId);
  });

  test('switching platform loads its default chart', () async {
    final List<String> requestedCharts = <String>[];
    final ProviderContainer container = _container(
      _repository(requestedCharts: requestedCharts),
    );
    await _start(container);

    await container
        .read(musicChartControllerProvider.notifier)
        .selectPlatform(MusicChartPlatform.tencent);
    final MusicChartState state = await _settle(container);

    expect(state.platform, MusicChartPlatform.tencent);
    expect(
      state.chart,
      MusicChartCatalog.defaultChartOf(MusicChartPlatform.tencent),
    );
    expect(state.charts, MusicChartCatalog.tencentCharts);
    expect(state.tracks, hasLength(1));
    expect(requestedCharts.last, state.chart.chartId);
  });

  test('switching chart keeps the platform and reloads tracks', () async {
    final List<String> requestedCharts = <String>[];
    final ProviderContainer container = _container(
      _repository(requestedCharts: requestedCharts),
    );
    await _start(container);

    final MusicChart target = MusicChartCatalog.chartsFor(
      MusicChartPlatform.kugou,
    )[2];
    await container
        .read(musicChartControllerProvider.notifier)
        .selectChart(target);
    final MusicChartState state = await _settle(container);

    expect(state.chart, target);
    expect(state.platform, MusicChartPlatform.kugou);
    expect(state.tracks.single.title, '歌曲 ${target.chartId}');
    expect(state.hasError, isFalse);
    expect(requestedCharts.last, target.chartId);
  });

  test('surfaces the failure message', () async {
    final ProviderContainer container = _container(_repository(fail: true));

    final MusicChartState state = await _start(container);

    expect(state.hasError, isTrue);
    expect(state.errorMessage, contains('榜单加载失败'));
    expect(state.tracks, isEmpty);
    expect(state.isEmpty, isFalse);
  });
}
