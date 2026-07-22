import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_cover_logic.g.dart';

@riverpod
class PlayerCoverLogic extends _$PlayerCoverLogic {
  @override
  bool? build() {
    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      if (previous?.currentItem?.stableId != next.currentItem?.stableId) {
        state = null;
      }
    });
    return null;
  }

  void toggle({required bool defaultUseMetadataCover}) {
    state = !(state ?? defaultUseMetadataCover);
  }
}
