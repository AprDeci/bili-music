import 'dart:io';

import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('首个地址失败时自动切换下一个镜像并校验下载结果', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'bilimusic-download-test',
    );
    addTearDown(() => directory.delete(recursive: true));

    final List<int> bytes = List<int>.generate(64 * 1024, (int i) => i % 251);
    final String sha256Hex = sha256.convert(bytes).toString();

    final HttpServer brokenServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    brokenServer.listen((HttpRequest request) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.close();
    });
    addTearDown(() => brokenServer.close(force: true));

    final HttpServer mirrorServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    mirrorServer.listen((HttpRequest request) {
      request.response.headers.contentLength = bytes.length;
      request.response.add(bytes);
      request.response.close();
    });
    addTearDown(() => mirrorServer.close(force: true));

    final String brokenUrl = 'http://127.0.0.1:${brokenServer.port}/apk';
    final String mirrorUrl = 'http://127.0.0.1:${mirrorServer.port}/apk';
    final List<String> selected = <String>[];

    final File file = await UpdateRepository().downloadApk(
      asset: UpdateAsset(
        name: 'bili-music-v1.8.2-arm64-v8a.apk',
        downloadUrl: mirrorUrl,
        sizeBytes: bytes.length,
        sha256Hex: sha256Hex,
      ),
      candidates: <String>[brokenUrl, mirrorUrl],
      onMirrorSelected: selected.add,
      onProgress: (int received, int total) {},
      directory: directory,
    );

    expect(selected, <String>[brokenUrl, mirrorUrl]);
    expect(file.path, endsWith('bili-music-v1.8.2-arm64-v8a.apk'));
    expect(await file.readAsBytes(), bytes);

    // 校验通过的缓存包会被复用，不再发起下载。
    final File reused = await UpdateRepository().downloadApk(
      asset: UpdateAsset(
        name: 'bili-music-v1.8.2-arm64-v8a.apk',
        downloadUrl: mirrorUrl,
        sizeBytes: bytes.length,
        sha256Hex: sha256Hex,
      ),
      candidates: <String>[brokenUrl],
      onMirrorSelected: selected.add,
      onProgress: (int received, int total) {},
      directory: directory,
    );

    expect(await reused.readAsBytes(), bytes);
    expect(selected, <String>[brokenUrl, mirrorUrl]);
  });
}
