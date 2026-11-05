import 'package:bilimusic/feature/meting/domain/meting_server.dart';

enum MusicChartPlatform {
  netease(server: MetingServer.netease, label: '网易云'),
  tencent(server: MetingServer.tencent, label: 'QQ音乐'),
  kugou(server: MetingServer.kugou, label: '酷狗');

  const MusicChartPlatform({required this.server, required this.label});

  final MetingServer server;
  final String label;
}
