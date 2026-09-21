import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDownloadException implements Exception {
  const UpdateDownloadException(this.message);

  final String message;

  @override
  String toString() => 'UpdateDownloadException: $message';
}

class UpdateRepository {
  UpdateRepository({Dio? dio}) : _dio = dio ?? _createDio();

  static const String releaseApiUrl =
      'https://api.github.com/repos/AprDeci/bili-music/releases/latest';
  static const String releaseListUrl =
      'https://github.com/AprDeci/bili-music/releases';

  /// 直接拼在 GitHub 资产地址前面的镜像前缀，官方直链会作为最后兜底。
  static const List<String> mirrorPrefixes = <String>[
    'https://gh-proxy.org/',
    'https://v6.gh-proxy.org/',
  ];

  static const Duration probeTimeout = Duration(seconds: 3);
  static const Duration downloadIdleTimeout = Duration(seconds: 30);
  static const Duration candidateTimeout = Duration(minutes: 6);

  final Dio _dio;
  final AppLogger _logger = AppLogger('UpdateRepository');

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
  }

  Future<UpdateRelease> fetchLatestRelease() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      releaseApiUrl,
      options: Options(
        headers: <String, dynamic>{
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );
    final Map<String, dynamic> json = asStringKeyedMap(response.data);
    final String tagName = (json['tag_name'] as String? ?? '').trim();
    if (tagName.isEmpty) {
      throw const FormatException('Latest release tag is missing.');
    }

    final String htmlUrl = (json['html_url'] as String? ?? '').trim();
    return UpdateRelease(
      tagName: tagName,
      title: (json['name'] as String? ?? '').trim(),
      body: (json['body'] as String? ?? '').trim(),
      htmlUrl: htmlUrl.isEmpty ? releaseListUrl : htmlUrl,
      assets: asListOfMaps(
        json['assets'],
      ).map(_parseAsset).nonNulls.toList(growable: false),
    );
  }

  UpdateAsset? _parseAsset(Map<String, dynamic> json) {
    final String name = (json['name'] as String? ?? '').trim();
    final String downloadUrl = (json['browser_download_url'] as String? ?? '')
        .trim();
    if (name.isEmpty || downloadUrl.isEmpty) {
      return null;
    }

    final String digest = (json['digest'] as String? ?? '').trim();
    return UpdateAsset(
      name: name,
      downloadUrl: downloadUrl,
      sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
      sha256Hex: digest.toLowerCase().startsWith('sha256:')
          ? digest.substring('sha256:'.length)
          : null,
    );
  }

  /// 镜像候选项：每个镜像前缀拼一次，最后追加官方直链兜底。
  static List<String> buildDownloadCandidates(String assetUrl) {
    return <String>[
      for (final String mirror in mirrorPrefixes)
        '${mirror.endsWith('/') ? mirror : '$mirror/'}$assetUrl',
      assetUrl,
    ];
  }

  /// 并发探测各候选地址，按响应延迟从快到慢排序，探测失败的排在最后。
  Future<List<String>> orderCandidatesByLatency(
    List<String> candidates, {
    required int expectedBytes,
  }) async {
    if (candidates.length < 2) {
      return candidates;
    }

    final List<Duration?> latencies = await Future.wait(
      candidates.map(
        (String url) => _probeLatency(url, expectedBytes: expectedBytes),
      ),
    );
    final List<String> ordered = orderByLatency(candidates, latencies);
    _logger.d('mirror probe: $ordered');
    return ordered;
  }

  static List<String> orderByLatency(
    List<String> candidates,
    List<Duration?> latencies,
  ) {
    final List<int> indexes = List<int>.generate(
      candidates.length,
      (int i) => i,
    );
    indexes.sort((int a, int b) {
      final Duration? left = a < latencies.length ? latencies[a] : null;
      final Duration? right = b < latencies.length ? latencies[b] : null;
      if (left == null || right == null) {
        if (left == right) {
          return a.compareTo(b);
        }
        return left == null ? 1 : -1;
      }
      final int compared = left.compareTo(right);
      return compared == 0 ? a.compareTo(b) : compared;
    });
    return indexes
        .map((int index) => candidates[index])
        .toList(growable: false);
  }

  /// 用 1 字节 Range 请求探测可达性并记录延迟。
  ///
  /// 各家代理普遍不支持 HEAD（实测 gh-proxy 全系列返回 502），只认 GET，
  /// 所以这里发 `Range: bytes=0-0` 的流式 GET，拿到响应头就立刻断开。
  Future<Duration?> _probeLatency(
    String url, {
    required int expectedBytes,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final Response<ResponseBody> response = await _dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: <String, dynamic>{'Accept': '*/*', 'Range': 'bytes=0-0'},
          receiveTimeout: probeTimeout,
          sendTimeout: probeTimeout,
          validateStatus: (int? status) => status != null && status < 400,
        ),
      );
      await response.data?.stream.listen(null).cancel();

      if (expectedBytes > 0) {
        final int? totalBytes = parseTotalBytes(
          contentRange: response.headers.value('content-range'),
          contentLength: response.headers.value(Headers.contentLengthHeader),
        );
        if (totalBytes != null && totalBytes != expectedBytes) {
          _logger.w('mirror rejected, size mismatch: $url -> $totalBytes');
          return null;
        }
      }
      return stopwatch.elapsed;
    } on Object catch (error) {
      _logger.w('mirror unreachable: $url -> $error');
      return null;
    }
  }

  /// 206 从 Content-Range 的 total 取全量大小，200 用 Content-Length。
  static int? parseTotalBytes({String? contentRange, String? contentLength}) {
    final int? rangeTotal = int.tryParse(
      (contentRange ?? '').split('/').last.trim(),
    );
    if (rangeTotal != null && rangeTotal > 0) {
      return rangeTotal;
    }

    final int? length = int.tryParse((contentLength ?? '').trim());
    return length != null && length > 0 ? length : null;
  }

  /// 按 [candidates] 顺序逐个尝试下载，成功且校验通过才返回本地文件。
  ///
  /// 每个候选都有硬性时限（Dio 的 receiveTimeout 只在完全收不到数据时生效，
  /// 缓慢但不中断的连接需要这里的兜底），超时即取消并换下一个地址。
  Future<File> downloadApk({
    required UpdateAsset asset,
    required List<String> candidates,
    required void Function(String url) onMirrorSelected,
    required void Function(int received, int total) onProgress,
    Directory? directory,
  }) async {
    final Directory targetDirectory =
        directory ?? await getTemporaryDirectory();
    final File file = File(
      '${targetDirectory.path}${Platform.pathSeparator}${asset.name}',
    );

    // 授权/安装失败后重试时复用已校验通过的缓存包，避免重复下载。
    if (await file.exists()) {
      try {
        await verifyApk(file, asset);
        _logger.d('reuse cached apk: ${file.path}');
        return file;
      } on UpdateDownloadException {
        // 缓存包不完整或校验失败，落到下面重新下载。
      }
    }

    Object? lastError;
    for (final String url in candidates) {
      onMirrorSelected(url);
      final CancelToken cancelToken = CancelToken();
      final Timer deadline = Timer(candidateTimeout, () {
        cancelToken.cancel('下载超时，切换下一个地址');
      });
      try {
        if (await file.exists()) {
          await file.delete();
        }
        await _dio.download(
          url,
          file.path,
          cancelToken: cancelToken,
          onReceiveProgress: onProgress,
          options: Options(
            receiveTimeout: downloadIdleTimeout,
            headers: <String, dynamic>{'Accept': 'application/octet-stream'},
          ),
        );

        await verifyApk(file, asset);

        return file;
      } on Object catch (error) {
        lastError = error;
        _logger.w('download failed: $url -> $error');
      } finally {
        deadline.cancel();
      }
    }

    throw UpdateDownloadException('所有下载地址均失败：$lastError');
  }

  /// 大小与 sha256 均与发布资产一致才算有效。
  static Future<void> verifyApk(File file, UpdateAsset asset) async {
    final int downloadedBytes = await file.length();
    if (asset.sizeBytes > 0 && downloadedBytes != asset.sizeBytes) {
      throw UpdateDownloadException(
        '安装包不完整（$downloadedBytes/${asset.sizeBytes} 字节）',
      );
    }

    final String? expectedSha256 = asset.sha256Hex;
    if (expectedSha256 == null) {
      return;
    }
    final String actualSha256 = await sha256HexOfFile(file);
    if (actualSha256.toLowerCase() != expectedSha256.toLowerCase()) {
      throw const UpdateDownloadException('安装包校验失败，已放弃该下载地址');
    }
  }

  static Future<String> sha256HexOfFile(File file) async {
    final Digest digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// 当前进程所在 Android ABI 对应的资产后缀；非 Android 返回 null。
  static String? currentAndroidAbiSuffix() {
    return switch (Abi.current()) {
      Abi.androidArm64 => 'arm64-v8a',
      Abi.androidArm => 'armeabi-v7a',
      Abi.androidX64 => 'x86_64',
      Abi.androidIA32 => 'x86',
      _ => null,
    };
  }

  /// 优先当前 ABI，缺资产时退回常见 64/32 位包。
  static List<String> abiSuffixCandidates({String? current}) {
    final String? primary = current ?? currentAndroidAbiSuffix();
    final List<String> suffixes = <String>[
      if (primary != null && primary.isNotEmpty) primary,
      'arm64-v8a',
      'armeabi-v7a',
    ];
    return suffixes.toSet().toList(growable: false);
  }
}
