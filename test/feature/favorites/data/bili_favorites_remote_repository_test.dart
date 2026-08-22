import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/favorites/data/bili_favorites_remote_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'manifest uses bvid-first stable IDs and filters unsupported types',
    () async {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient(<String, dynamic>{
        'code': 0,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'type': 2, 'bvid': 'BV1'},
          <String, dynamic>{'id': 2, 'type': 2, 'bv_id': 'BV2'},
          <String, dynamic>{'id': 3, 'type': 2},
          <String, dynamic>{'id': 4, 'type': 12, 'bvid': 'BV4'},
        ],
      });
      final BiliFavoritesRemoteRepository repository =
          BiliFavoritesRemoteRepository(client: client);

      final List<FavoriteRemoteResource> manifest = await repository
          .fetchCollectionItemManifest(session: _session(), remoteId: '123');
      expect(
        manifest.map((FavoriteRemoteResource resource) => resource.stableId),
        <String>['bvid:BV1', 'bvid:BV2', 'aid:3'],
      );
      expect(client.queryParameters, <String, dynamic>{
        'media_id': '123',
        'platform': 'web',
      });
      expect(manifest[0].stableId, 'bvid:BV1');
      expect(manifest[0].aid, 1);
      expect(manifest[0].bvid, 'BV1');
    },
  );
}

class _FakeBiliHttpClient implements BiliHttpClient {
  _FakeBiliHttpClient(this.response);

  final Map<String, dynamic> response;
  Map<String, dynamic>? queryParameters;
  String? path;

  @override
  BiliSession? get currentSession => null;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) async {
    this.queryParameters = queryParameters;
    this.path = path;
    return Response<T>(
      data: response as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BiliSession _session() {
  return const BiliSession(
    sessData: 'sess',
    biliJct: 'csrf',
    dedeUserId: '1',
    refreshToken: '',
    cookie: 'SESSDATA=sess',
  );
}
