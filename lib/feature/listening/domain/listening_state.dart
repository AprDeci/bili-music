import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'listening_state.freezed.dart';

@freezed
abstract class ListeningState with _$ListeningState {
  const factory ListeningState({
    String? warning,
    ListeningProgress? localConflict,
    ListeningProgress? remoteConflict,
  }) = _ListeningState;
}
