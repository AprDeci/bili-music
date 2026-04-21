import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_response.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_logic.g.dart';

@riverpod
MetingLogic metingLogic(Ref ref) {
  return MetingLogic(repository: ref.read(metingRepositoryProvider));
}

class MetingLogic {
  MetingLogic({required this._repository});

  final MetingRepository _repository;

  final _logger = AppLogger('MetingLogic');

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

  Future<MetingSearchItem?> find({
    required String title,
    MetingServer server = MetingServer.netease,
  }) async {
    final String query = extractSearchKeyword(title);
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
    return _extractName(value);
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

  String _extractName(String value) {
    String result = value.trim();
    final priorityRegex = RegExp(r'《(.+?)》|「(.+?)」');
    final priorityMatch = priorityRegex.firstMatch(result);

    if (priorityMatch != null) {
      final group1 = priorityMatch.group(1);
      final group2 = priorityMatch.group(2);

      _logger.d(
        '匹配到优先提取的标记，直接返回这段字符串作为 keyword：'
        '${group1 ?? ''}, ${group2 ?? ''}',
      );

      return group1 ?? group2 ?? '';
    }

    // 移除 【...】 和 “...”
    final replacedKeyword = result
        .replaceAll(RegExp(r'【.*?】|“.*?”'), '')
        .trim();

    result = replacedKeyword.isNotEmpty ? replacedKeyword : result;

    _logger.d('最终 keyword 清洗后：$result');

    return result;
  }
}
