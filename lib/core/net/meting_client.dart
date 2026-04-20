import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:bilimusic/feature/meting/logic/meting_settings_logic.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_client.g.dart';

@riverpod
class MetingClient extends _$MetingClient {
  final AppLogger _logger = AppLogger('MetingClient');

  @override
  Dio build() {
    final String configuredBaseUrl = ref.watch(metingSettingsLogicProvider);
    _dio = Dio(
      BaseOptions(
        baseUrl: configuredBaseUrl,
        connectTimeout: NetConfig.connectTimeout,
        receiveTimeout: NetConfig.receiveTimeout,
        sendTimeout: NetConfig.sendTimeout,
        responseType: ResponseType.json,
        headers: NetConfig.defaultHeaders,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: AppLogger.dioLogPrint,
      ),
    );
    _logger.i('Dio client initialized');
    return _dio;
  }

  late final Dio _dio;

  Dio get dio => _dio;

  bool get isConfigured => _dio.options.baseUrl.trim().isNotEmpty;
}
