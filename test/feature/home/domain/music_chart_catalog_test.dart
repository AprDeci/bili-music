import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every platform exposes its own charts', () {
    for (final MusicChartPlatform platform in MusicChartPlatform.values) {
      final List<MusicChart> charts = MusicChartCatalog.chartsFor(platform);

      expect(charts, isNotEmpty, reason: '${platform.name} 没有配置榜单');
      expect(
        charts.every((MusicChart chart) => chart.platform == platform),
        isTrue,
        reason: '${platform.name} 榜单平台不匹配',
      );
    }
  });

  test('chart ids and names are unique inside a platform', () {
    for (final MusicChartPlatform platform in MusicChartPlatform.values) {
      final List<MusicChart> charts = MusicChartCatalog.chartsFor(platform);
      final Set<String> chartIds = <String>{
        for (final MusicChart chart in charts) chart.chartId,
      };
      final Set<String> names = <String>{
        for (final MusicChart chart in charts) chart.name,
      };

      expect(
        chartIds,
        hasLength(charts.length),
        reason: '${platform.name} 榜单 id 重复',
      );
      expect(
        names,
        hasLength(charts.length),
        reason: '${platform.name} 榜单名称重复',
      );
    }
  });

  test('chart ids look like native chart identifiers', () {
    for (final MusicChartPlatform platform in MusicChartPlatform.values) {
      for (final MusicChart chart in MusicChartCatalog.chartsFor(platform)) {
        expect(
          chart.chartId,
          matches(RegExp(r'^\d+$')),
          reason: '${chart.displayTitle} 的榜单 id 非法',
        );
        expect(chart.name.trim(), isNotEmpty);
      }
    }
  });

  test('chart keys are unique across all platforms', () {
    final List<MusicChart> charts = <MusicChart>[
      for (final MusicChartPlatform platform in MusicChartPlatform.values)
        ...MusicChartCatalog.chartsFor(platform),
    ];
    final Set<String> keys = <String>{
      for (final MusicChart chart in charts) chart.key,
    };

    expect(keys, hasLength(charts.length));
  });

  test('default chart belongs to the requested platform', () {
    for (final MusicChartPlatform platform in MusicChartPlatform.values) {
      final MusicChart chart = MusicChartCatalog.defaultChartOf(platform);

      expect(chart.platform, platform);
      expect(chart, MusicChartCatalog.chartsFor(platform).first);
    }
    expect(
      MusicChartCatalog.defaultChart,
      MusicChartCatalog.defaultChartOf(MusicChartPlatform.netease),
    );
  });

  test('display title prefixes the platform label', () {
    const MusicChart chart = MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '26',
      name: '热歌榜',
    );

    expect(chart.displayTitle, 'QQ音乐热歌榜');
    expect(chart.key, 'tencent:26');
  });
}
