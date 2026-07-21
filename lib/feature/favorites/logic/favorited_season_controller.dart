import 'package:bilimusic/feature/favorites/data/favorited_season_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorited_season_controller.g.dart';

@riverpod
FavoritedSeasonLocalRepository favoritedSeasonLocalRepository(Ref ref) {
  return FavoritedSeasonLocalRepository(
    Hive.box<FavoritedSeason>(favoritedSeasonsBoxName),
  );
}

@Riverpod(keepAlive: true)
class FavoritedSeasonController extends _$FavoritedSeasonController {
  late final FavoritedSeasonLocalRepository _repository = ref.read(
    favoritedSeasonLocalRepositoryProvider,
  );

  @override
  List<FavoritedSeason> build() => _repository.load();

  Future<void> initialize() async {
    state = _repository.load();
  }

  bool isFavorited(int seasonId) {
    return state.any((FavoritedSeason season) => season.seasonId == seasonId);
  }

  Future<bool> toggle(UpCollection collection) async {
    final FavoritedSeason? previous = _repository.get(collection.seasonId);
    if (previous != null) {
      state = await _repository.delete(collection.seasonId);
      return false;
    }

    state = await _repository.save(FavoritedSeason.fromCollection(collection));
    return true;
  }

  Future<void> syncIfFavorited(UpCollection collection) async {
    final FavoritedSeason? previous = _repository.get(collection.seasonId);
    if (previous == null) {
      return;
    }
    state = await _repository.save(
      FavoritedSeason.fromCollection(collection, previous: previous),
    );
  }

  Future<void> remove(int seasonId) async {
    state = await _repository.delete(seasonId);
  }
}
