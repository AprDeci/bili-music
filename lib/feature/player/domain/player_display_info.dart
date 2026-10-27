import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_display_info.freezed.dart';

enum PlayerDisplaySource { metadata, bilibili }

@freezed
abstract class PlayerDisplayInfo with _$PlayerDisplayInfo {
  const factory PlayerDisplayInfo({
    String? stableId,
    String? title,
    String? artist,
    String? coverUrl,
    @Default(PlayerDisplaySource.metadata) PlayerDisplaySource source,
    @Default(false) bool canToggleSource,
    int? artistUpMid,
  }) = _PlayerDisplayInfo;
}
