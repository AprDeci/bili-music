import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/session/bili_auth_required_exception.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/bili/sign/bili_wbi_signer.dart';
import 'package:bilimusic/core/net/net_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_client.g.dart';

enum BiliRequestMode { defaultCookie, anonymous }

abstract interface class BiliHttpClient {
  BiliSession? get currentSession;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth,
    bool requiresWbi,
    BiliRequestMode mode,
    Options? options,
  });

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode,
  });

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
}

@Riverpod(keepAlive: true)
class BiliClient extends _$BiliClient implements BiliHttpClient {
  final AppLogger _logger = AppLogger('BiliClient');

  @override
  Dio build() {
    _dio = Dio(
      BaseOptions(
        baseUrl: NetConfig.baseUrl,
        connectTimeout: NetConfig.connectTimeout,
        receiveTimeout: NetConfig.receiveTimeout,
        sendTimeout: NetConfig.sendTimeout,
        responseType: ResponseType.json,
        headers: NetConfig.defaultHeaders,
      ),
    );

    // 匿名模式下，移除Cookie
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (options.extra['biliRequestMode'] == BiliRequestMode.anonymous) {
            options.headers.remove('Cookie');
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          logPrint: AppLogger.dioLogPrint,
        ),
      );
    }
    _logger.i('Dio client initialized');
    return _dio;
  }

  late final Dio _dio;

  Dio get dio => _dio;

  @override
  BiliSession? get currentSession => ref.read(biliSessionControllerProvider);

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) async {
    final BiliSession? session = currentSession;
    if (requiresAuth && (session == null || !session.isLoggedIn)) {
      throw const BiliAuthRequiredException();
    }

    final Map<String, dynamic> params = _buildQueryParameters(
      session: session,
      queryParameters: queryParameters,
      requiresWbi: requiresWbi,
    );

    final Response<dynamic> response;
    try {
      response = await get<dynamic>(
        path,
        queryParameters: params,
        options: options,
        mode: mode,
      );
    } on DioException catch (error) {
      throw _mapDioError(error, session);
    }

    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    return json;
  }

  // 未登录时的 403/412 统一成鉴权异常，已登录保持原样
  Exception _mapDioError(DioException error, BiliSession? session) {
    final int status = error.response?.statusCode ?? 0;
    if (!(session?.isLoggedIn ?? false) && (status == 403 || status == 412)) {
      return const BiliAuthRequiredException();
    }
    return error;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _withRequestMode(options, mode),
      cancelToken: cancelToken,
    );
  }

  Options? _withRequestMode(Options? options, BiliRequestMode mode) {
    if (mode == BiliRequestMode.defaultCookie) {
      return options;
    }
    return (options ?? Options()).copyWith(
      extra: <String, dynamic>{...?options?.extra, 'biliRequestMode': mode},
    );
  }

  Map<String, dynamic> _buildQueryParameters({
    required BiliSession? session,
    required Map<String, dynamic>? queryParameters,
    required bool requiresWbi,
  }) {
    final Map<String, dynamic> params = <String, dynamic>{...?queryParameters};
    if (!requiresWbi) {
      return params;
    }
    if (session == null) {
      throw const BiliApiException(
        'Bilibili session is required for WBI APIs.',
      );
    }
    return ref
        .read(biliWbiSignerProvider)
        .sign(queryParameters: params, session: session);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    try {
      return asStringKeyedMap(value);
    } on FormatException {
      throw const BiliApiException('Unexpected response format.');
    }
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    final int code = (json['code'] as num? ?? -1).toInt();
    if (code != 0) {
      throw biliApiErrorFromCode(
        code,
        loggedIn: currentSession?.isLoggedIn ?? false,
        message: json['message'] as String?,
      );
    }
  }

  @override
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

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  void setCookie(String cookie) {
    setHeader('Cookie', cookie);
  }

  void clearCookie() {
    removeHeader('Cookie');
  }
}

// 未登录时 -101/-352/-403 统一成鉴权异常；
Exception biliApiErrorFromCode(
  int code, {
  required bool loggedIn,
  String? message,
}) {
  if (!loggedIn && (code == -101 || code == -352 || code == -403)) {
    return BiliAuthRequiredException(message ?? '登录后可用');
  }
  return BiliApiException(message ?? 'Request failed.', code: code);
}

class BiliApiException implements Exception {
  const BiliApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}
