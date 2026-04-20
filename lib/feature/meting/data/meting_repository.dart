import 'package:bilimusic/core/net/meting_client.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_repository.g.dart';

@riverpod
MetingRepository metingRepository(Ref ref) {
  return MetingRepository(ref.read(metingClientProvider));
}

class MetingRepository {
  const MetingRepository(this._dio);

  final Dio _dio;

  Future<List<MetingSearchItem>> search({
    required String keyword,
    MetingServer server = MetingServer.netease,
  }) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return const <MetingSearchItem>[];
    }

    if (_dio.options.baseUrl.trim().isEmpty) {
      throw const MetingException('请先在播放器设置中配置 Meting API 地址。');
    }

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api',
        queryParameters: <String, dynamic>{
          'server': server.apiValue,
          'type': 'search',
          'id': trimmedKeyword,
        },
      );
      final dynamic data = response.data;
      if (data is! List<dynamic>) {
        throw const MetingException('Meting API 返回格式异常。');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(_mapSearchItem)
          .toList(growable: false);
    } on MetingException {
      rethrow;
    } on DioException catch (error) {
      throw MetingException(_describeDioError(error));
    } on Object catch (error) {
      throw MetingException('Meting API 请求失败：$error');
    }
  }

  Future<String> fetchLyrics(MetingSearchItem item) async {
    final String lrcUrl = item.lrc.trim();
    if (lrcUrl.isEmpty) {
      throw const MetingException('当前歌曲没有歌词地址。');
    }

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        lrcUrl,
        options: Options(responseType: ResponseType.plain),
      );
      final dynamic data = response.data;
      if (data is String) {
        return data;
      }
      throw const MetingException('Meting API 歌词返回格式异常。');
    } on MetingException {
      rethrow;
    } on DioException catch (error) {
      throw MetingException(_describeDioError(error));
    } on Object catch (error) {
      throw MetingException('Meting API 请求失败：$error');
    }
  }

  MetingSearchItem _mapSearchItem(Map<String, dynamic> json) {
    return MetingSearchItem(
      title: _readString(json['title']),
      author: _readString(json['author']),
      url: _readString(json['url']),
      pic: _readString(json['pic']),
      lrc: _readString(json['lrc']),
    );
  }

  String _readString(Object? value) {
    return value is String ? value : '';
  }

  String _describeDioError(DioException error) {
    final String message = error.message?.trim() ?? '';
    if (message.isEmpty) {
      return 'Meting API 请求失败。';
    }
    return 'Meting API 请求失败：$message';
  }
}

class MetingException implements Exception {
  const MetingException(this.message);

  final String message;

  @override
  String toString() => message;
}
