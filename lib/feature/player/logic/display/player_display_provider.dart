import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_display_provider.g.dart';

// 统一显示入口
@riverpod
PlayerDisplayInfo playerDisplay(Ref ref) {
  final item = ref.watch(
    playerControllerProvider.select((state) => state.currentItem),
  );
  final metadata = ref.watch(
    metadataControllerProvider.select(
      (state) => (stableId: state.stableId, metadata: state.metadata),
    ),
  );
  final PlayerDisplaySource source =
      ref.watch(playerDisplaySourceLogicProvider) ??
      (ref.watch(playerDisplaySettingsLogicProvider)
          ? PlayerDisplaySource.metadata
          : PlayerDisplaySource.bilibili);
  return resolvePlayerDisplayInfo(
    item: item,
    metadata: metadata.stableId == item?.stableId ? metadata.metadata : null,
    source: source,
  );
}
