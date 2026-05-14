import 'dart:convert';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/net/bm_client.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_logic.g.dart';

@riverpod
MetingLogic metingLogic(Ref ref) {
  return MetingLogic(
    repository: ref.read(metingRepositoryProvider),
    bmClient: ref.read(bmClientProvider.notifier),
  );
}

class MetingLogic {
  MetingLogic({required this._repository, this._bmClient});

  final MetingRepository _repository;
  final BmClient? _bmClient;

  final AppLogger _logger = AppLogger('MetingLogic');

  Future<MetingSearchResponse> search({
    required String keyword,
    MetingServer server = MetingServer.netease,
  }) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return const MetingSearchResponse(
        keyword: '',
        results: <MetingSearchItem>[],
      );
    }

    final List<MetingSearchItem> results = await _repository.search(
      keyword: trimmedKeyword,
      server: server,
    );
    return MetingSearchResponse(keyword: trimmedKeyword, results: results);
  }

  Future<String> fetchLyrics(MetingSearchItem item) {
    return _repository.fetchLyrics(item);
  }

  Future<String> fetchPicture(MetingSearchItem item, {int size = 300}) {
    return _repository.fetchPicture(item, size: size);
  }

  Future<MetingSearchItem?> find({
    required String title,
    MetingServer server = MetingServer.netease,
  }) async {
    final String query = await resolveSearchKeyword(title);
    if (query.isEmpty) {
      return null;
    }

    final List<MetingSearchItem> results = (await search(
      keyword: query,
      server: resolveServer(title, server: server),
    )).results;
    return results.isEmpty ? null : results.first;
  }

  Future<String?> findLyrics({
    required String title,
    MetingServer server = MetingServer.netease,
  }) async {
    server = resolveServer(title, server: server);
    final MetingSearchItem? item = await find(title: title, server: server);
    if (item == null) {
      return null;
    }
    return _repository.fetchLyrics(item);
  }

  String extractSearchKeyword(String value) {
    String result = value.trim();
    final RegExp priorityRegex = RegExp(r'《(.+?)》|「(.+?)」');
    final RegExpMatch? priorityMatch = priorityRegex.firstMatch(result);

    if (priorityMatch != null) {
      final String? group1 = priorityMatch.group(1);
      final String? group2 = priorityMatch.group(2);

      _logger.d(
        '匹配到优先提取的标记，直接返回这段字符串作为 keyword：'
        '${group1 ?? ''}, ${group2 ?? ''}',
      );

      return group1 ?? group2 ?? '';
    }

    final String replacedKeyword = result
        .replaceAll(RegExp(r'【.*?】|“.*?”'), '')
        .trim();

    result = replacedKeyword.isNotEmpty ? replacedKeyword : result;

    _logger.d('最终 keyword 清洗后：$result');

    return result;
  }

  Future<String> resolveSearchKeyword(String value) async {
    final String rawTitle = value.trim();
    if (rawTitle.isEmpty) {
      return '';
    }

    final String fallbackKeyword = extractSearchKeyword(rawTitle).trim();
    final BmClient? bmClient = _bmClient;
    if (bmClient == null) {
      return fallbackKeyword;
    }

    try {
      final Response<String> response = await bmClient.post<String>(
        '/ai',
        data: <String, dynamic>{'message': rawTitle},
        options: Options(responseType: ResponseType.plain),
      );
      final String keyword = jsonDecode(response.data ?? '{}') ?? '';
      if (keyword.isNotEmpty) {
        return keyword;
      }
    } on Object catch (error) {
      _logger.d('BM 识别失败，回退正则：$error');
    }

    return fallbackKeyword;
  }

  MetingServer resolveServer(
    String value, {
    MetingServer server = MetingServer.netease,
  }) {
    if (value.contains('周杰伦') ||
        value.contains('jay') ||
        value.contains('Jay')) {
      return MetingServer.kugou;
    }
    return server;
  }
}
