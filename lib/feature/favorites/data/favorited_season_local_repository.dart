import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:hive_ce/hive.dart';

const String favoritedSeasonsBoxName = 'favorited_seasons';

class FavoritedSeasonLocalRepository {
  const FavoritedSeasonLocalRepository(this._box);

  final Box<FavoritedSeason> _box;

  List<FavoritedSeason> load() {
    return _box.values.toList(growable: false)..sort(
      (FavoritedSeason a, FavoritedSeason b) =>
          b.favoritedAtEpochMs.compareTo(a.favoritedAtEpochMs),
    );
  }

  FavoritedSeason? get(int seasonId) => _box.get(seasonId);

  Future<List<FavoritedSeason>> save(FavoritedSeason season) async {
    await _box.put(season.seasonId, season);
    return load();
  }

  Future<List<FavoritedSeason>> delete(int seasonId) async {
    await _box.delete(seasonId);
    return load();
  }
}
