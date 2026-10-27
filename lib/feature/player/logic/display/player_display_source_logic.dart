import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_display_source_logic.g.dart';

@riverpod
class PlayerDisplaySourceLogic extends _$PlayerDisplaySourceLogic {
  @override
  PlayerDisplaySource? build() {
    ref.watch(
      playerControllerProvider.select((state) => state.currentItem?.stableId),
    );
    return null;
  }

  void toggle() {
    final PlayerDisplaySource current =
        state ??
        (ref.read(playerDisplaySettingsLogicProvider)
            ? PlayerDisplaySource.metadata
            : PlayerDisplaySource.bilibili);
    state = current == PlayerDisplaySource.metadata
        ? PlayerDisplaySource.bilibili
        : PlayerDisplaySource.metadata;
  }
}
