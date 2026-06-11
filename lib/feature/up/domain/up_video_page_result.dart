import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';

part 'up_video_page_result.freezed.dart';

@freezed
abstract class UpVideoPageResult with _$UpVideoPageResult {
  const factory UpVideoPageResult({
    required List<UpVideoItem> items,
    required int page,
    required bool hasMore,
  }) = _UpVideoPageResult;
}
