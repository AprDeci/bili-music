import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata_backfill_state.freezed.dart';

@freezed
abstract class MetadataBackfillState with _$MetadataBackfillState {
  const factory MetadataBackfillState({
    @Default(false) bool isRunning,
    @Default(0) int processed,
    @Default(0) int total,
    @Default(0) int matched,
  }) = _MetadataBackfillState;
}
