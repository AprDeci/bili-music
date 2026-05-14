import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata_state.freezed.dart';

@freezed
abstract class MetadataState with _$MetadataState {
  const factory MetadataState({
    String? stableId,
    Metadata? metadata,
    String? errorMessage,
    String? searchKeyword,
    String? manualSearchError,
    @Default(<MetingSearchItem>[]) List<MetingSearchItem> searchResults,
    @Default(false) bool isSearching,
    @Default(false) bool isLoading,
    @Default(false) bool hasSearched,
  }) = _MetadataState;

  const MetadataState._();

  bool get hasLyrics => metadata?.hasLyrics ?? false;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasNoLyrics => hasSearched && !hasLyrics && !hasError;
}
