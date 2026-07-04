import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_sync_repository.g.dart';

@riverpod
ClipboardSyncRepository clipboardSyncRepository(Ref ref) {
  return ClipboardSyncRepository();
}

class ClipboardSyncRepository {
  ClipboardSyncRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jq.torgw.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;

  Future<String?> loadContent(String clipboardName) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/clipboard/${Uri.encodeComponent(clipboardName)}',
      );
      final Map<String, dynamic> data = _asMap(response.data);
      if (data['requirePassword'] == true) {
        throw const ClipboardSyncException('网络剪贴板需要密码，当前同步未配置密码。');
      }
      return data['content'] as String? ?? '';
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ClipboardSyncException(_messageForDioError(error));
    }
  }

  Future<void> saveContent({
    required String clipboardName,
    required String content,
  }) async {
    try {
      try {
        await _postContent(clipboardName: clipboardName, content: content);
      } on DioException catch (error) {
        if (!_isClipboardMissingError(error)) {
          rethrow;
        }
        await _openClipboardPage(clipboardName);
        await _postContent(clipboardName: clipboardName, content: content);
      }
      await ensurePermanent(clipboardName);
    } on DioException catch (error) {
      throw ClipboardSyncException(_messageForDioError(error));
    }
  }

  Future<void> _postContent({
    required String clipboardName,
    required String content,
  }) async {
    await _dio.post<dynamic>(
      '/api/clipboard/${Uri.encodeComponent(clipboardName)}',
      data: <String, dynamic>{
        'content': content,
        'files': const <Object>[],
        'tabs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'name': 'bilimusic',
            'content': content,
            'files': const <Object>[],
          },
        ],
        'currentTabIndex': 0,
        'password': null,
      },
    );
  }

  Future<void> _openClipboardPage(String clipboardName) async {
    await _dio.get<dynamic>('/${Uri.encodeComponent(clipboardName)}');
  }

  Future<void> ensurePermanent(String clipboardName) async {
    try {
      await _dio.put<dynamic>(
        '/api/clipboard/${Uri.encodeComponent(clipboardName)}/settings',
        data: const <String, dynamic>{
          'expireHours': 0,
          'currentPassword': null,
        },
      );
    } on DioException catch (error) {
      throw ClipboardSyncException(_messageForDioError(error));
    }
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (Object? key, Object? value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }

  String _messageForDioError(DioException error) {
    final String? responseMessage = _responseMessage(error);
    if (responseMessage != null) {
      return responseMessage;
    }
    final int? statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return '网络剪贴板请求失败（HTTP $statusCode）。';
    }
    return error.message ?? '网络剪贴板请求失败。';
  }

  bool _isClipboardMissingError(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final String? responseMessage = _responseMessage(error);
    return (statusCode == 404 || statusCode == 500) &&
        responseMessage != null &&
        responseMessage.contains('剪贴板不存在');
  }

  String? _responseMessage(DioException error) {
    final Object? responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final Object? message = responseData['error'] ?? responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

class ClipboardSyncException implements Exception {
  const ClipboardSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
