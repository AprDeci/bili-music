import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.freezed.dart';

enum DownloadTaskStatus { queued, running, failed }

@freezed
abstract class DownloadTask with _$DownloadTask {
  const DownloadTask._();

  const factory DownloadTask({
    required PlayableItem item,
    @Default(DownloadTaskStatus.queued) DownloadTaskStatus status,
    @Default(0) int receivedBytes,
    @Default(0) int totalBytes,
    String? errorMessage,
  }) = _DownloadTask;

  String get contentId => item.contentId;

  double? get progress =>
      totalBytes <= 0 ? null : (receivedBytes / totalBytes).clamp(0.0, 1.0);

  bool get isActive =>
      status == DownloadTaskStatus.queued ||
      status == DownloadTaskStatus.running;

  Map<String, Object?> toJson() => <String, Object?>{
    'item': <String, Object?>{
      'aid': item.aid,
      'bvid': item.bvid,
      'cid': item.cid,
      'page': item.page,
      'pageTitle': item.pageTitle,
      'title': item.title,
      'author': item.author,
      'coverUrl': item.coverUrl,
      'kind': item.kind.name,
      'collectionId': item.collectionId,
    },
    'status': status.name,
    'receivedBytes': receivedBytes,
    'totalBytes': totalBytes,
    'errorMessage': status != DownloadTaskStatus.failed
        ? null
        : const <String>{
            '下载超时，请检查网络后重试',
            '网络连接失败，请检查网络后重试',
            '下载失败，请检查网络、登录状态或存储空间后重试',
          }.contains(errorMessage)
        ? errorMessage
        : '下载失败，请重试',
  };

  static DownloadTask? fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['item'] is! Map<String, dynamic>) {
      return null;
    }
    try {
      final Map<String, dynamic> json = value['item'] as Map<String, dynamic>;
      final int aid = json['aid'] as int;
      final String bvid = json['bvid'] as String;
      final int? cid = json['cid'] as int?;
      final int? page = json['page'] as int?;
      final int receivedBytes = value['receivedBytes'] as int? ?? 0;
      final int totalBytes = value['totalBytes'] as int? ?? 0;
      if (aid < 0 ||
          (aid == 0 && bvid.isEmpty) ||
          (cid != null && cid < 0) ||
          (page != null && page <= 0) ||
          receivedBytes < 0 ||
          totalBytes < 0) {
        return null;
      }
      return DownloadTask(
        item: PlayableItem(
          aid: aid,
          bvid: bvid,
          cid: cid,
          page: page,
          pageTitle: json['pageTitle'] as String?,
          title: json['title'] as String,
          author: json['author'] as String,
          coverUrl: json['coverUrl'] as String,
          kind: CollectionKind.values.firstWhere(
            (CollectionKind kind) => kind.name == (json['kind'] ?? 'music'),
          ),
          collectionId: json['collectionId'] as String?,
        ),
        status: DownloadTaskStatus.values.firstWhere(
          (DownloadTaskStatus status) =>
              status.name == (value['status'] ?? 'queued'),
        ),
        receivedBytes: receivedBytes,
        totalBytes: totalBytes,
        errorMessage: value['errorMessage'] as String?,
      );
    } on Object {
      return null;
    }
  }
}
