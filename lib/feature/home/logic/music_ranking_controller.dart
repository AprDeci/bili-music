import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/home/data/bili_music_ranking_repository.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_ranking_controller.g.dart';

@Riverpod(keepAlive: true)
BiliMusicRankingRepository biliMusicRankingRepository(Ref ref) {
  return BiliMusicRankingRepository(ref.read(biliApiClientProvider));
}

@riverpod
Future<List<MusicRankingItem>> musicRanking(Ref ref) async {
  final BiliSession? session = ref.read(biliSessionControllerProvider);
  final bool shouldUseWbi =
      session != null && session.isLoggedIn && session.hasWbiKeys;
  const blackTagList = ['杂谈', '乐评', '仿妆', '教学', '明星', '时尚潮流'];
  final List<MusicRankingItem> items = await ref
      .read(biliMusicRankingRepositoryProvider)
      .fetchMusicRanking(requiresWbi: shouldUseWbi);
  return items
      .where((item) {
        final tag = item.tagText;
        // 检查标签文本是否包含黑名单中的任意一个字符串
        return !blackTagList.any((blackTag) => tag.contains(blackTag));
      })
      .toList(growable: false);
}
