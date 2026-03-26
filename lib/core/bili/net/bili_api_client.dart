import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/bili/sign/bili_wbi_signer.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_api_client.g.dart';

@riverpod
BiliApiClient biliApiClient(Ref ref) {
  return BiliApiClient(
    ref: ref,
    client: ref.read(biliClientProvider.notifier),
    signer: ref.read(biliWbiSignerProvider),
  );
}

class BiliApiClient {
  const BiliApiClient({
    required this.ref,
    required this.client,
    required this.signer,
  });

  final Ref ref;
  final BiliClient client;
  final BiliWbiSigner signer;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    Options? options,
  }) async {
    final BiliSession? session = ref.read(biliSessionControllerProvider);
    if (requiresAuth && session == null) {
      throw const BiliApiException('Bilibili session is required.');
    }

    final Map<String, dynamic>? params = _buildQueryParameters(
      session: session,
      queryParameters: queryParameters,
      requiresWbi: requiresWbi,
    );

    final Response<dynamic> response = await client.get<dynamic>(
      path,
      queryParameters: params,
      options: options,
    );

    final Map<String, dynamic> json = _asMap(response.data);
    _ensureSuccess(json);
    return json;
  }

  Map<String, dynamic> _buildQueryParameters({
    required BiliSession? session,
    required Map<String, dynamic>? queryParameters,
    required bool requiresWbi,
  }) {
    final Map<String, dynamic> params = <String, dynamic>{
      ...?queryParameters,
    };
    if (!requiresWbi) {
      return params;
    }
    if (session == null) {
      throw const BiliApiException('Bilibili session is required for WBI APIs.');
    }
    return signer.sign(queryParameters: params, session: session);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) =>
            MapEntry(key.toString(), mapValue),
      );
    }
    throw const BiliApiException('Unexpected response format.');
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    final int code = (json['code'] as num? ?? -1).toInt();
    if (code != 0) {
      throw BiliApiException(json['message'] as String? ?? 'Request failed.');
    }
  }
}

class BiliApiException implements Exception {
  const BiliApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
