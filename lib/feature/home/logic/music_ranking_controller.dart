import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/home/data/bili_music_ranking_repository.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_ranking_controller.g.dart';

@Riverpod(keepAlive: true)
BiliMusicRankingRepository biliMusicRankingRepository(Ref ref) {
  return BiliMusicRankingRepository(ref.read(biliApiClientProvider));
}

@riverpod
Future<List<MusicRankingItem>> musicRanking(Ref ref) {
  return ref.read(biliMusicRankingRepositoryProvider).fetchMusicRanking();
}
