import 'package:freezed_annotation/freezed_annotation.dart';

part 'updater_state.freezed.dart';

enum UpdatePhase { idle, probing, downloading, installing }

@freezed
abstract class UpdaterState with _$UpdaterState {
  const factory UpdaterState({
    @Default(UpdatePhase.idle) UpdatePhase phase,
    @Default(0) int totalBytes,
    String? mirrorHost,
  }) = _UpdaterState;

  const UpdaterState._();

  bool get isBusy =>
      phase == UpdatePhase.probing ||
      phase == UpdatePhase.downloading ||
      phase == UpdatePhase.installing;
}
