import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bilibili_comment_repository.g.dart';

@riverpod
BiliCommentRepository biliCommentRepository(Ref ref) {
  return BiliCommentRepository(ref.read(biliApiClientProvider));
}

class BiliCommentRepository {
  const BiliCommentRepository(this._apiClient);

  static const int _defaultPageSize = 20;

  final BiliApiClient _apiClient;

  Future<CommentPageResult> fetchRootComments(
    CommentTarget target, {
    int page = 1,
    CommentSort sort = CommentSort.time,
    bool includeHot = true,
  }) async {
    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/v2/reply',
      queryParameters: <String, dynamic>{
        'type': target.type,
        'oid': target.oid,
        'sort': sort.apiValue,
        'pn': page,
        'ps': _defaultPageSize,
        'nohot': includeHot ? 0 : 1,
      },
      requiresAuth: true,
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> pageInfo = _asMapOrEmpty(data['page']);
    final Map<String, dynamic> config = _asMapOrEmpty(data['config']);
    final Map<String, dynamic> upper = _asMapOrEmpty(data['upper']);
    final Map<String, dynamic>? notice = _asNullableMap(data['notice']);

    final List<CommentItem> items = _asListOfMaps(
      data['replies'],
    ).map(_mapCommentItem).toList();

    final List<CommentItem> hotItems = _asListOfMaps(
      data['hots'],
    ).map(_mapCommentItem).toList();

    final Map<String, dynamic>? rawTop = _asNullableMap(upper['top']);
    final CommentItem? topItem = rawTop == null
        ? null
        : _mapCommentItem(rawTop, isTop: true);

    final int resolvedPage = _readPositiveInt(pageInfo['num']) ?? page;
    final int pageSize = _readPositiveInt(pageInfo['size']) ?? _defaultPageSize;
    final int totalCount = _readNonNegativeInt(pageInfo['count']) ?? 0;

    return CommentPageResult(
      items: items,
      hotItems: hotItems,
      topItem: topItem,
      page: resolvedPage,
      pageSize: pageSize,
      totalCount: totalCount,
      hasMore: _hasMore(
        currentPage: resolvedPage,
        pageSize: pageSize,
        totalCount: totalCount,
        itemCount: items.length,
      ),
      isReadOnly: config['read_only'] as bool? ?? false,
      noticeText: _readNoticeText(notice),
    );
  }

  CommentItem _mapCommentItem(Map<String, dynamic> json, {bool isTop = false}) {
    final Map<String, dynamic> member = _asMapOrEmpty(json['member']);
    final Map<String, dynamic> content = _asMapOrEmpty(json['content']);

    final List<CommentItem> previewReplies = _asListOfMaps(
      json['replies'],
    ).map(_mapCommentItem).toList();

    final int timestamp = _readNonNegativeInt(json['ctime']) ?? 0;

    return CommentItem(
      rpid: _readNonNegativeInt(json['rpid']) ?? 0,
      oid: _readNonNegativeInt(json['oid']) ?? 0,
      type: _readNonNegativeInt(json['type']) ?? 0,
      root: _readNonNegativeInt(json['root']) ?? 0,
      parent: _readNonNegativeInt(json['parent']) ?? 0,
      replyCount:
          _readNonNegativeInt(json['count']) ??
          _readNonNegativeInt(json['rcount']) ??
          previewReplies.length,
      likeCount: _readNonNegativeInt(json['like']) ?? 0,
      action: _readNonNegativeInt(json['action']) ?? 0,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      message: content['message'] as String? ?? '',
      memberName: member['uname'] as String? ?? '未知用户',
      memberAvatarUrl: _normalizeUrl(member['avatar'] as String? ?? ''),
      isTop: isTop,
      isHidden: json['invisible'] as bool? ?? false,
      replies: previewReplies,
    );
  }

  bool _hasMore({
    required int currentPage,
    required int pageSize,
    required int totalCount,
    required int itemCount,
  }) {
    if (totalCount > 0 && pageSize > 0) {
      return currentPage * pageSize < totalCount;
    }

    return itemCount >= pageSize && itemCount > 0;
  }

  String? _readNoticeText(Map<String, dynamic>? notice) {
    if (notice == null) {
      return null;
    }
    final String text = notice['content'] as String? ?? '';
    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _normalizeUrl(String value) {
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }
    return 'https://$value';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    throw const BiliCommentException('Unexpected comment response format.');
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return null;
  }

  Map<String, dynamic> _asMapOrEmpty(dynamic value) {
    return _asNullableMap(value) ?? <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    final List<dynamic> list = value as List<dynamic>? ?? <dynamic>[];
    return list.whereType<Map>().map((Map item) {
      return item.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }).toList();
  }

  int? _readPositiveInt(dynamic value) {
    if (value is num) {
      final int intValue = value.toInt();
      return intValue > 0 ? intValue : null;
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return null;
  }

  int? _readNonNegativeInt(dynamic value) {
    if (value is num) {
      final int intValue = value.toInt();
      return intValue >= 0 ? intValue : null;
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
    }
    return null;
  }
}

class BiliCommentException implements Exception {
  const BiliCommentException(this.message);

  final String message;

  @override
  String toString() => message;
}
