import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

class DownloadedTrack {
  const DownloadedTrack({
    required this.contentId,
    required this.aid,
    required this.bvid,
    required this.cid,
    required this.page,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.filePath,
    required this.byteLength,
    required this.downloadedAtMs,
    this.pageTitle,
    this.durationMs,
    this.qualityId,
    this.qualityLabel,
    this.bandwidth,
    this.collectionId,
    this.kind = CollectionKind.music,
  });

  final String contentId;
  final int aid;
  final String bvid;
  final int cid;
  final int page;
  final String title;
  final String author;
  final String coverUrl;
  final String filePath;
  final int byteLength;
  final int downloadedAtMs;
  final String? pageTitle;
  final int? durationMs;
  final int? qualityId;
  final String? qualityLabel;
  final int? bandwidth;
  final String? collectionId;
  final CollectionKind kind;

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      cid: cid,
      page: page,
      pageTitle: pageTitle,
      title: title,
      author: author,
      coverUrl: coverUrl,
      kind: kind,
      collectionId: collectionId,
      durationText: durationMs == null ? null : _formatDuration(durationMs!),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'contentId': contentId,
      'aid': aid,
      'bvid': bvid,
      'cid': cid,
      'page': page,
      'pageTitle': pageTitle,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'filePath': filePath,
      'byteLength': byteLength,
      'downloadedAtMs': downloadedAtMs,
      'durationMs': durationMs,
      'qualityId': qualityId,
      'qualityLabel': qualityLabel,
      'bandwidth': bandwidth,
      'collectionId': collectionId,
      'kind': kind.name,
    };
  }

  static DownloadedTrack? fromJson(Object? value) {
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    int? readInt(String key) {
      final Object? raw = value[key];
      return raw is num ? raw.toInt() : null;
    }

    final String? contentId = value['contentId'] as String?;
    final String? filePath = value['filePath'] as String?;
    final int? byteLength = readInt('byteLength');
    final int? cid = readInt('cid');
    if (contentId == null ||
        contentId.isEmpty ||
        filePath == null ||
        filePath.isEmpty ||
        byteLength == null ||
        cid == null) {
      return null;
    }

    return DownloadedTrack(
      contentId: contentId,
      aid: readInt('aid') ?? 0,
      bvid: value['bvid'] as String? ?? '',
      cid: cid,
      page: readInt('page') ?? 1,
      pageTitle: value['pageTitle'] as String?,
      title: value['title'] as String? ?? '',
      author: value['author'] as String? ?? '',
      coverUrl: value['coverUrl'] as String? ?? '',
      filePath: filePath,
      byteLength: byteLength,
      downloadedAtMs: readInt('downloadedAtMs') ?? 0,
      durationMs: readInt('durationMs'),
      qualityId: readInt('qualityId'),
      qualityLabel: value['qualityLabel'] as String?,
      bandwidth: readInt('bandwidth'),
      collectionId: value['collectionId'] as String?,
      kind: CollectionKind.values.firstWhere(
        (CollectionKind kind) => kind.name == value['kind'],
        orElse: () => CollectionKind.music,
      ),
    );
  }

  static String _formatDuration(int durationMs) {
    final int totalSeconds = durationMs ~/ 1000;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    final String mmss =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return hours > 0 ? '${hours.toString().padLeft(2, '0')}:$mmss' : mmss;
  }
}
