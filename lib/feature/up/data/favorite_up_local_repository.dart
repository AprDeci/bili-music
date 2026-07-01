import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_local_repository.g.dart';

const String favoriteUpsBoxName = 'favorite_ups';

@riverpod
FavoriteUpLocalRepository favoriteUpLocalRepository(Ref ref) {
  return FavoriteUpLocalRepository(Hive.box<FavoriteUp>(favoriteUpsBoxName));
}

class FavoriteUpLocalRepository {
  const FavoriteUpLocalRepository(this._box);

  final Box<FavoriteUp> _box;

  List<FavoriteUp> load() {
    return _box.values.toList(growable: false)..sort(
      (FavoriteUp a, FavoriteUp b) =>
          b.favoritedAtEpochMs.compareTo(a.favoritedAtEpochMs),
    );
  }

  FavoriteUp? get(int mid) {
    return _box.get(mid);
  }

  Future<List<FavoriteUp>> save(FavoriteUp up) async {
    await _box.put(up.mid, up);
    return load();
  }

  Future<List<FavoriteUp>> delete(int mid) async {
    await _box.delete(mid);
    return load();
  }
}
