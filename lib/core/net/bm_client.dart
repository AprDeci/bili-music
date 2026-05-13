import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bm_client.g.dart';

@riverpod
class BmClient extends _$BmClient {
  final AppLogger _logger = AppLogger('BmClient');

  @override
  Dio build() {
    _dio = Dio(
      BaseOptions(
        baseUrl: NetConfig.bmBaseUrl,
        connectTimeout: NetConfig.connectTimeout,
        receiveTimeout: NetConfig.receiveTimeout,
        sendTimeout: NetConfig.sendTimeout,
        responseType: ResponseType.json,
        headers: NetConfig.bmHeaders,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: AppLogger.dioLogPrint,
      ),
    );
    _logger.i('BM Dio client initialized');
    return _dio;
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
