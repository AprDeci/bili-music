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
class MusicRankingController extends _$MusicRankingController {
  @override
  FutureOr<List<MusicRankingItem>> build() async {
    return _fetchData();
  }

  // 提取获取数据的逻辑，方便刷新时复用
  Future<List<MusicRankingItem>> _fetchData() async {
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
          return !blackTagList.any((blackTag) => tag.contains(blackTag));
        })
        .toList(growable: false);
  }

  
  Future<void> refresh() async {
    state = const AsyncLoading(); 
    state = await AsyncValue.guard(_fetchData);
  }
}
