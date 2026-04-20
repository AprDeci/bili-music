import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_lyrics_state.freezed.dart';

@freezed
abstract class PlayerLyricsState with _$PlayerLyricsState {
  const factory PlayerLyricsState({
    String? stableId,
    String? rawLyrics,
    String? errorMessage,
    @Default(false) bool isLoading,
    @Default(false) bool hasSearched,
  }) = _PlayerLyricsState;

  const PlayerLyricsState._();

  bool get hasLyrics => rawLyrics != null && rawLyrics!.trim().isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasNoLyrics => hasSearched && !hasLyrics && !hasError;
}
