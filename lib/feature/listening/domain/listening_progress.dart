import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'listening_progress.freezed.dart';
part 'listening_progress.g.dart';

@freezed
abstract class ListeningProgress with _$ListeningProgress {
  const ListeningProgress._();

  const factory ListeningProgress({
    required String accountId,
    required int aid,
    required String bvid,
    required int cid,
    @Default(1) int page,
    @Default(0) int positionMs,
    @Default(0) int durationMs,
    @Default(0) int updatedAtMs,
    @Default(false) bool completed,
    @Default(false) bool pendingSync,
    String? collectionId,
  }) = _ListeningProgress;

  factory ListeningProgress.fromJson(Map<String, dynamic> json) =>
      _$ListeningProgressFromJson(json);

  String get videoId => bvid.isNotEmpty ? 'bvid:$bvid' : 'aid:$aid';
  String get key => '$accountId:$videoId:cid:$cid';
  bool get isValid =>
      accountId.isNotEmpty &&
      aid >= 0 &&
      (aid > 0 || bvid.isNotEmpty) &&
      cid > 0 &&
      page > 0 &&
      positionMs >= 0 &&
      durationMs >= 0 &&
      updatedAtMs >= 0;

  bool matchesVideo(PlayableItem item) =>
      bvid.isNotEmpty && item.bvid.isNotEmpty
      ? bvid == item.bvid
      : aid > 0 && aid == item.aid;

  bool matchesChapter(PlayableItem item) =>
      matchesVideo(item) && cid == item.cid;

  Duration get resumePosition =>
      completed ? Duration.zero : Duration(milliseconds: positionMs);
}
