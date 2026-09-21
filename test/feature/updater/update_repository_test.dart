import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String assetUrl =
      'https://github.com/AprDeci/bili-music/releases/download/v1.8.2/'
      'bili-music-v1.8.2-arm64-v8a.apk';

  test('按 ABI 后缀挑 APK 资产，缺失时回退', () {
    const UpdateRelease release = UpdateRelease(
      tagName: 'v1.8.2',
      title: '',
      body: '',
      htmlUrl: '',
      assets: <UpdateAsset>[
        UpdateAsset(
          name: 'bili-music-v1.8.2-armeabi-v7a.apk',
          downloadUrl: 'https://example.com/v7a.apk',
        ),
        UpdateAsset(
          name: 'bili-music-v1.8.2-arm64-v8a.apk',
          downloadUrl: 'https://example.com/v8a.apk',
        ),
        UpdateAsset(
          name: 'bili-music-v1.8.2.ipa',
          downloadUrl: 'https://example.com/app.ipa',
        ),
      ],
    );

    expect(
      release.selectApkAsset(<String>['x86_64', 'arm64-v8a'])?.name,
      'bili-music-v1.8.2-arm64-v8a.apk',
    );
    expect(
      release.selectApkAsset(<String>['x86_64', 'armeabi-v7a'])?.name,
      'bili-music-v1.8.2-armeabi-v7a.apk',
    );
    expect(release.selectApkAsset(<String>['x86_64']), isNull);
  });

  test('探测结果按延迟排序，不可达的排最后', () {
    final List<String> ordered = UpdateRepository.orderByLatency(
      <String>['slow', 'dead', 'fast'],
      <Duration?>[
        const Duration(milliseconds: 900),
        null,
        const Duration(milliseconds: 120),
      ],
    );

    expect(ordered, <String>['fast', 'slow', 'dead']);
  });

  test('从 206 的 Content-Range 或 200 的 Content-Length 取全量大小', () {
    expect(
      UpdateRepository.parseTotalBytes(
        contentRange: 'bytes 0-0/29406092',
        contentLength: '1',
      ),
      29406092,
    );
    expect(
      UpdateRepository.parseTotalBytes(contentLength: '29406092'),
      29406092,
    );
    expect(
      UpdateRepository.parseTotalBytes(
        contentRange: 'bytes 0-0/*',
        contentLength: '29406092',
      ),
      29406092,
    );
    expect(UpdateRepository.parseTotalBytes(), isNull);
  });

  test('sha256 校验值按文件内容计算', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'bilimusic-update-test',
    );
    addTearDown(() => directory.delete(recursive: true));

    final List<int> bytes = utf8.encode('bili-music');
    final File file = File('${directory.path}${Platform.pathSeparator}apk')
      ..writeAsBytesSync(bytes);

    expect(
      await UpdateRepository.sha256HexOfFile(file),
      sha256.convert(bytes).toString(),
    );
  });

  test('缓存安装包按大小与 sha256 判定是否可复用', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'bilimusic-update-cache-test',
    );
    addTearDown(() => directory.delete(recursive: true));

    final List<int> bytes = utf8.encode('bili-music-apk');
    final File file = File('${directory.path}${Platform.pathSeparator}apk')
      ..writeAsBytesSync(bytes);
    final String sha256Hex = sha256.convert(bytes).toString();

    await expectLater(
      UpdateRepository.verifyApk(
        file,
        UpdateAsset(
          name: 'bili-music-v1.8.2-arm64-v8a.apk',
          downloadUrl: assetUrl,
          sizeBytes: bytes.length,
          sha256Hex: sha256Hex,
        ),
      ),
      completes,
    );

    await expectLater(
      UpdateRepository.verifyApk(
        file,
        UpdateAsset(
          name: 'bili-music-v1.8.2-arm64-v8a.apk',
          downloadUrl: assetUrl,
          sizeBytes: bytes.length,
          sha256Hex:
              'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        ),
      ),
      throwsA(isA<UpdateDownloadException>()),
    );

    await expectLater(
      UpdateRepository.verifyApk(
        file,
        UpdateAsset(
          name: 'bili-music-v1.8.2-arm64-v8a.apk',
          downloadUrl: assetUrl,
          sizeBytes: bytes.length + 1,
          sha256Hex: sha256Hex,
        ),
      ),
      throwsA(isA<UpdateDownloadException>()),
    );
  });

  test('ABI 候选去重且当前 ABI 优先', () {
    expect(UpdateRepository.abiSuffixCandidates(current: 'arm64-v8a'), <String>[
      'arm64-v8a',
      'armeabi-v7a',
    ]);
    expect(UpdateRepository.abiSuffixCandidates(current: 'x86_64'), <String>[
      'x86_64',
      'arm64-v8a',
      'armeabi-v7a',
    ]);
  });
}
