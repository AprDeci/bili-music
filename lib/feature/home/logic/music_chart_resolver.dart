import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_resolver.g.dart';

@riverpod
MusicChartResolver musicChartResolver(Ref ref) {
  return MusicChartResolver(
    searchRepository: ref.read(biliSearchRepositoryProvider),
    playerRepository: ref.read(biliPlayerRepositoryProvider),
  );
}

class MusicChartResolver {
  const MusicChartResolver({
    required this.searchRepository,
    required this.playerRepository,
  });

  final BiliSearchRepository searchRepository;
  final BiliPlayerRepository playerRepository;

  Future<PlayableItem?> resolve(MusicChartTrack track) async {
    final SearchResultItem? match =
        await _searchBest(track.searchKeyword, track) ??
        await _searchBest(track.title, track);
    if (match == null) {
      return null;
    }
    return playerRepository.resolvePreferredPart(
      match.toPlayableItem(),
      preferredPage: 1,
    );
  }

  Future<SearchResultItem?> _searchBest(
    String keyword,
    MusicChartTrack track,
  ) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return null;
    }
    final SearchPageResult result = await searchRepository.searchVideos(
      trimmedKeyword,
    );
    return ChartTrackMatcher.pickBest(track: track, candidates: result.items);
  }
}
