import 'package:bilimusic/feature/meting/domain/meting_server.dart';

enum MusicChartPlatform {
  netease(
    server: MetingServer.netease,
    label: '网易云',
    title: '网易云热歌榜',
    chartId: '3778678',
  ),
  tencent(
    server: MetingServer.tencent,
    label: 'QQ音乐',
    title: 'QQ音乐热歌榜',
    chartId: '7011264344',
  ),
  kugou(
    server: MetingServer.kugou,
    label: '酷狗',
    title: '酷狗TOP500',
    chartId: '8888',
  );

  const MusicChartPlatform({
    required this.server,
    required this.label,
    required this.title,
    required this.chartId,
  });

  final MetingServer server;
  final String label;
  final String title;
  final String chartId;
}
