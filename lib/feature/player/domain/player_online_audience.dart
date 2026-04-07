import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_online_audience.freezed.dart';

@freezed
abstract class PlayerOnlineAudience with _$PlayerOnlineAudience {
  const factory PlayerOnlineAudience({
    String? totalText,
    String? countText,
    @Default(false) bool showTotal,
    @Default(false) bool showCount,
    required DateTime fetchedAt,
  }) = _PlayerOnlineAudience;

  const PlayerOnlineAudience._();

  bool get hasVisibleValue =>
      (showTotal && (totalText?.isNotEmpty ?? false)) ||
      (showCount && (countText?.isNotEmpty ?? false));
}
