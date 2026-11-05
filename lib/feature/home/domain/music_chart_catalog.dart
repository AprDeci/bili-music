import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';

abstract final class MusicChartCatalog {
  static const MusicChart _neteaseHot = MusicChart(
    platform: MusicChartPlatform.netease,
    chartId: '3778678',
    name: '热歌榜',
  );

  static const List<MusicChart> neteaseCharts = <MusicChart>[
    _neteaseHot,
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '19723756',
      name: '飙升榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '3779629',
      name: '新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '2884035',
      name: '原创榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '7785066739',
      name: '黑胶VIP热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '7785123708',
      name: '黑胶VIP新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '991319590',
      name: '中文说唱榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '1978921795',
      name: '电音榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '71385702',
      name: 'ACG榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '5059642708',
      name: '国风榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '5059661515',
      name: '民谣榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '5059633707',
      name: '摇滚榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '745956260',
      name: '韩语榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '5059644681',
      name: '日语榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '2809513713',
      name: '欧美热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '2809577409',
      name: '欧美新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '2250011882',
      name: '抖音排行榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '71384707',
      name: '古典榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '60198',
      name: '美国Billboard榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '180106',
      name: 'UK排行榜周榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.netease,
      chartId: '60131',
      name: '日本Oricon榜',
    ),
  ];

  static const List<MusicChart> tencentCharts = <MusicChart>[
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '26',
      name: '热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '62',
      name: '飙升榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '27',
      name: '新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '4',
      name: '流行指数榜',
    ),
    MusicChart(platform: MusicChartPlatform.tencent, chartId: '5', name: '内地榜'),
    MusicChart(platform: MusicChartPlatform.tencent, chartId: '6', name: '港台榜'),
    MusicChart(platform: MusicChartPlatform.tencent, chartId: '3', name: '欧美榜'),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '16',
      name: '韩国榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '17',
      name: '日本榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '58',
      name: '说唱榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '57',
      name: '电音榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '72',
      name: '动漫音乐榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '29',
      name: '影视金曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '64',
      name: '综艺新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '65',
      name: '国风热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '60',
      name: '抖音热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '63',
      name: 'DJ舞曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '28',
      name: '网络歌曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '73',
      name: '游戏音乐榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '67',
      name: '听歌识曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '108',
      name: '美国公告牌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '107',
      name: '英国UK榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '105',
      name: '日本公信榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.tencent,
      chartId: '129',
      name: '韩国Melon榜',
    ),
  ];

  static const List<MusicChart> kugouCharts = <MusicChart>[
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '8888',
      name: 'TOP500',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '6666',
      name: '飙升榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '74534',
      name: '新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '31308',
      name: '内地榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '85897',
      name: '国潮音乐榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '51341',
      name: '民谣榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '33160',
      name: '电音榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '82831',
      name: '网络热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '24971',
      name: 'DJ热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '33165',
      name: '粤语金曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '31310',
      name: '欧美榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '31311',
      name: '韩国榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '31312',
      name: '日本榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '31313',
      name: '香港地区榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '54848',
      name: '台湾地区榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '33162',
      name: 'ACG新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '33163',
      name: '影视金曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '46910',
      name: '综艺新歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '59896',
      name: '摇滚榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '59900',
      name: '纯音乐榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '35811',
      name: '会员热歌榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '85432',
      name: '百万收藏榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '4681',
      name: '美国BillBoard榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '4680',
      name: '英国单曲榜',
    ),
    MusicChart(
      platform: MusicChartPlatform.kugou,
      chartId: '38623',
      name: '韩国Melon音乐榜',
    ),
  ];

  static const MusicChart defaultChart = _neteaseHot;

  static List<MusicChart> chartsFor(MusicChartPlatform platform) {
    return switch (platform) {
      MusicChartPlatform.netease => neteaseCharts,
      MusicChartPlatform.tencent => tencentCharts,
      MusicChartPlatform.kugou => kugouCharts,
    };
  }

  static MusicChart defaultChartOf(MusicChartPlatform platform) {
    return chartsFor(platform).first;
  }
}
