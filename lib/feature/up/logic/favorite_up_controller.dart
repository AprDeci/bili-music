import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_controller.g.dart';

@Riverpod(keepAlive: true)
class FavoriteUpController extends _$FavoriteUpController {
  late final FavoriteUpLocalRepository _repository = ref.read(
    favoriteUpLocalRepositoryProvider,
  );

  @override
  List<FavoriteUp> build() {
    return _repository.load();
  }

  Future<void> initialize() async {
    state = _repository.load();
  }

  bool isFavorited(int mid) {
    return state.any((FavoriteUp up) => up.mid == mid);
  }

  Future<bool> toggle(UpProfile profile) async {
    final FavoriteUp? previous = _repository.get(profile.mid);
    if (previous != null) {
      state = await _repository.delete(profile.mid);
      return false;
    }

    state = await _repository.save(FavoriteUp.fromProfile(profile));
    return true;
  }

  Future<void> remove(int mid) async {
    state = await _repository.delete(mid);
  }
}
