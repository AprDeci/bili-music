import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_blacklist_entry.freezed.dart';
part 'player_blacklist_entry.g.dart';

@freezed
abstract class PlayerBlacklistEntry with _$PlayerBlacklistEntry {
  const PlayerBlacklistEntry._();

  const factory PlayerBlacklistEntry({
    required String stableId,
    required int aid,
    required String bvid,
    required String title,
    required String author,
    required String coverUrl,
    int? ownerMid,
    int? cid,
    int? page,
    String? pageTitle,
    required int addedAtEpochMs,
  }) = _PlayerBlacklistEntry;

  factory PlayerBlacklistEntry.fromJson(Map<String, dynamic> json) =>
      _$PlayerBlacklistEntryFromJson(json);

  factory PlayerBlacklistEntry.fromPlayableItem(
    PlayableItem item, {
    DateTime? now,
  }) {
    return PlayerBlacklistEntry(
      stableId: item.stableId,
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      author: item.author,
      coverUrl: item.coverUrl,
      ownerMid: item.ownerMid,
      cid: item.cid,
      page: item.page,
      pageTitle: item.pageTitle,
      addedAtEpochMs: (now ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  String get displayTitle {
    final String trimmedPageTitle = pageTitle?.trim() ?? '';
    if (trimmedPageTitle.isEmpty) {
      return title;
    }

    return trimmedPageTitle;
  }

  String get displaySubtitle {
    final String trimmedPageTitle = pageTitle?.trim() ?? '';
    if (trimmedPageTitle.isNotEmpty) {
      return title;
    }
    return author;
  }
}
