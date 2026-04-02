import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
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

  static const String _mainPath = '/x/v2/reply/wbi/main';
  static final AppLogger _logger = AppLogger('BiliCommentRepository');

  final BiliApiClient _apiClient;

  Future<CommentPageResult> fetchRootComments(
    CommentTarget target, {
    int page = 1,
    String? nextOffset,
    CommentSort sort = CommentSort.time,
    bool includeHot = true,
  }) async {
    final BiliSession? session = _apiClient.ref.read(
      biliSessionControllerProvider,
    );
    final bool shouldSignWithWbi = session?.isReady ?? false;

    _logger.d(
      'fetchRootComments start '
      'oid=${target.oid} '
      'type=${target.type} '
      'sort=$sort '
      'page=$page '
      'nextOffset=$nextOffset '
      'includeHot=$includeHot '
      'shouldSignWithWbi=$shouldSignWithWbi',
    );

    return _fetchMainComments(
      target,
      sort: sort,
      nextOffset: nextOffset,
      includeHot: includeHot,
      shouldSignWithWbi: shouldSignWithWbi,
    );
  }

  Future<CommentPageResult> _fetchMainComments(
    CommentTarget target, {
    required CommentSort sort,
    required String? nextOffset,
    required bool includeHot,
    required bool shouldSignWithWbi,
  }) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      'type': target.type,
      'oid': target.oid,
      'mode': _mainMode(sort),
      'plat': 1,
      'web_location': 1315875,
      if (nextOffset != null && nextOffset.isNotEmpty)
        'pagination_str': _buildPaginationStr(nextOffset),
    };

    _logger.d(
      'fetchMainComments request '
      'mode=${queryParameters['mode']} '
      'pagination=${queryParameters['pagination_str']} '
      'requiresWbi=$shouldSignWithWbi',
    );

    final Map<String, dynamic> json = await _apiClient.getJson(
      _mainPath,
      queryParameters: queryParameters,
      requiresAuth: false,
      requiresWbi: shouldSignWithWbi,
    );

    final Map<String, dynamic> data = _asMap(json['data']);
    final Map<String, dynamic> cursor = _asMapOrEmpty(data['cursor']);
    final Map<String, dynamic> config = _asMapOrEmpty(data['config']);
    final Map<String, dynamic> folder = _asMapOrEmpty(data['folder']);
    final Map<String, dynamic> top = _asMapOrEmpty(data['top']);
    final Map<String, dynamic>? notice = _asNullableMap(data['notice']);
    final List<Map<String, dynamic>> rawReplyMaps = _asListOfMaps(
      data['replies'],
    );
    final List<Map<String, dynamic>> rawHotMaps = includeHot
        ? _asListOfMaps(data['hots'])
        : const <Map<String, dynamic>>[];

    final String? resolvedNextOffset = _readNextOffset(cursor);
    final bool isEnd = _readBoolLike(cursor['is_end']) ?? false;
    final int totalCount =
        _readNonNegativeInt(cursor['all_count']) ?? rawReplyMaps.length;

    _logger.d(
      'fetchMainComments response '
      'allCount=${cursor['all_count']} '
      'isEnd=$isEnd '
      'rawReplies=${rawReplyMaps.length} '
      'rawHots=${rawHotMaps.length} '
      'nextOffset=$resolvedNextOffset '
      'hasTopUpper=${_asNullableMap(top['upper']) != null} '
      'hasTopAdmin=${_asNullableMap(top['admin']) != null} '
      'hasFolded=${folder['has_folded']} '
      'isFolded=${folder['is_folded']}',
    );

    final List<CommentItem> items = _mapCommentList(
      rawReplyMaps,
      sourceLabel: 'main.replies',
    );

    final List<CommentItem> hotItems = _mapCommentList(
      rawHotMaps,
      sourceLabel: 'main.hots',
    );

    final CommentItem? topItem = _pickTopComment(top);
    final List<CommentSort> supportedSorts = _mapSupportedSorts(
      cursor['support_mode'],
    );

    _logger.d(
      'fetchMainComments mapped '
      'items=${items.length} '
      'hots=${hotItems.length} '
      'top=${topItem != null} '
      'supportedSorts=$supportedSorts '
      'sortTitle=${cursor['name']}',
    );

    return CommentPageResult(
      items: items,
      hotItems: hotItems,
      topItem: topItem,
      page: _readPositiveInt(cursor['next']) ?? 1,
      pageSize: items.length,
      totalCount: totalCount,
      hasMore: !isEnd,
      nextOffset: resolvedNextOffset,
      supportedSorts: supportedSorts,
      sortTitle: cursor['name'] as String?,
      isEnd: isEnd,
      hasFolded: _readBoolLike(folder['has_folded']) ?? false,
      isFolded: _readBoolLike(folder['is_folded']) ?? false,
      isReadOnly: _readBoolLike(config['read_only']) ?? false,
      noticeText: _readNoticeText(notice),
    );
  }

  List<CommentItem> _mapCommentList(
    List<Map<String, dynamic>> source, {
    required String sourceLabel,
  }) {
    final List<CommentItem> result = <CommentItem>[];

    for (int index = 0; index < source.length; index++) {
      final Map<String, dynamic> item = source[index];
      try {
        result.add(_mapCommentItem(item));
      } on Object catch (error, stackTrace) {
        _logger.e(
          'map $sourceLabel[$index] failed '
          'rpid=${item['rpid']} '
          'oid=${item['oid']} '
          'keys=${item.keys.toList()}',
          error,
          stackTrace,
        );
      }
    }

    return result;
  }

  int _mainMode(CommentSort sort) {
    switch (sort) {
      case CommentSort.hybrid:
        return 1;
      case CommentSort.time:
        return 2;
      case CommentSort.like:
        return 3;
    }
  }

  String _buildPaginationStr(String nextOffset) {
    final String escapedOffset = nextOffset.replaceAll('"', r'\"');
    return '{"offset":"$escapedOffset"}';
  }

  String? _readNextOffset(Map<String, dynamic> cursor) {
    final Map<String, dynamic> paginationReply = _asMapOrEmpty(
      cursor['pagination_reply'],
    );
    final String? value = paginationReply['next_offset'] as String?;
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  List<CommentSort> _mapSupportedSorts(dynamic value) {
    final List<dynamic> rawList = value as List<dynamic>? ?? <dynamic>[];
    final List<CommentSort> result = <CommentSort>[];

    for (final dynamic item in rawList) {
      final int? rawMode = _readNonNegativeInt(item);
      if (rawMode == null) {
        continue;
      }

      final CommentSort? mapped = _commentSortFromMode(rawMode);
      if (mapped != null && !result.contains(mapped)) {
        result.add(mapped);
      }
    }

    return result;
  }

  CommentSort? _commentSortFromMode(int mode) {
    switch (mode) {
      case 1:
        return CommentSort.hybrid;
      case 2:
        return CommentSort.time;
      case 3:
        return CommentSort.like;
    }
    return null;
  }

  CommentItem? _pickTopComment(Map<String, dynamic> top) {
    final Map<String, dynamic>? upper = _asNullableMap(top['upper']);
    final Map<String, dynamic>? admin = _asNullableMap(top['admin']);
    final Map<String, dynamic>? vote = _asNullableMap(top['vote']);
    final Map<String, dynamic>? selected = upper ?? admin ?? vote;
    if (selected == null) {
      return null;
    }

    try {
      return _mapCommentItem(selected, isTop: true);
    } on Object catch (error, stackTrace) {
      _logger.e('map main top comment failed', error, stackTrace);
      return null;
    }
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
      isHidden: _readBoolLike(json['invisible']) ?? false,
      replies: previewReplies,
    );
  }

  String? _readNoticeText(Map<String, dynamic>? notice) {
    if (notice == null) {
      return null;
    }
    final String text = notice['content'] as String? ?? '';
    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool? _readBoolLike(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      if (value == 'true' || value == '1') {
        return true;
      }
      if (value == 'false' || value == '0') {
        return false;
      }
    }
    return null;
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
