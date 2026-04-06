import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateUtil {
  UpdateUtil._();

  static final AppLogger logger = AppLogger('UpdateUtil');

  static const String _releaseApiUrl =
      'https://api.github.com/repos/AprDeci/bili-music/releases/latest';
  static const String _releaseListUrl =
      'https://github.com/AprDeci/bili-music/releases';
  static Future<void> checkAndPromptForUpdate(
    BuildContext context, {
    bool manual = false,
  }) async {
    logger.d('checkAndPromptForUpdate manual: $manual');
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final _ParsedVersion? currentVersion = _ParsedVersion.tryParse(
        packageInfo.version,
      );
      if (currentVersion == null) {
        if (manual && context.mounted) {
          _showSnackBar(context, '检查更新失败');
        }
        return;
      }

      final _ReleaseInfo release = await _fetchLatestRelease();
      final _ParsedVersion? latestVersion = _ParsedVersion.tryParse(
        release.tagName,
      );
      if (latestVersion == null) {
        if (manual && context.mounted) {
          _showSnackBar(context, '检查更新失败');
        }
        return;
      }

      if (latestVersion.compareTo(currentVersion) <= 0) {
        if (manual && context.mounted) {
          _showSnackBar(context, '当前已是最新版本');
        }
        return;
      }

      final String? dismissedTag = _loadDismissedTag();
      if (!manual && dismissedTag == release.tagName) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      final _UpdateAction? action = await _showUpdateDialog(
        context,
        currentVersion: currentVersion.displayValue,
        latestVersion: latestVersion.displayValue,
        release: release,
      );
      if (!context.mounted || action == null) {
        return;
      }

      await _saveDismissedTag(release.tagName);

      if (action == _UpdateAction.openReleasePage) {
        await launchUrl(
          Uri.parse(release.htmlUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } on Object {
      if (manual && context.mounted) {
        _showSnackBar(context, '检查更新失败');
      }
    }
  }

  static Future<_ReleaseInfo> _fetchLatestRelease() async {
    logger.d('fetchLatestRelease');
    final Dio dio = Dio(
      BaseOptions(
        headers: <String, dynamic>{
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(LogInterceptor());
    final Response<dynamic> response = await dio.get<dynamic>(_releaseApiUrl);
    logger.d('fetchLatestRelease response: $response');
    final Map<String, dynamic> json = _asMap(response.data);
    final String tagName = (json['tag_name'] as String? ?? '').trim();
    if (tagName.isEmpty) {
      throw const FormatException('Latest release tag is missing.');
    }

    final String htmlUrl = (json['html_url'] as String? ?? '').trim();

    logger.d('fetchLatestRelease tagName: $tagName, htmlUrl: $htmlUrl');

    return _ReleaseInfo(
      tagName: tagName,
      title: (json['name'] as String? ?? '').trim(),
      body: (json['body'] as String? ?? '').trim(),
      htmlUrl: htmlUrl.isEmpty ? _releaseListUrl : htmlUrl,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    return asStringKeyedMap(value);
  }

  static String? _loadDismissedTag() {
    final String value =
        Hive.box<String>(
          HiveBoxNames.prefs,
        ).get(HiveKeys.updateDismissedTag, defaultValue: '') ??
        '';
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  static Future<void> _saveDismissedTag(String tagName) {
    return Hive.box<String>(
      HiveBoxNames.prefs,
    ).put(HiveKeys.updateDismissedTag, tagName);
  }

  static Future<_UpdateAction?> _showUpdateDialog(
    BuildContext context, {
    required String currentVersion,
    required String latestVersion,
    required _ReleaseInfo release,
  }) {
    final ThemeData theme = Theme.of(context);
    final String title = release.title.isEmpty
        ? '发现新版本 ${release.tagName}'
        : release.title;
    final String body = release.body.isEmpty ? '暂无更新说明' : release.body;

    return showDialog<_UpdateAction>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('更新内容', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SelectableText(body),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(_UpdateAction.later),
              child: const Text('稍后'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_UpdateAction.openReleasePage),
              child: const Text('前往更新'),
            ),
          ],
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _UpdateAction { later, openReleasePage }

class _ReleaseInfo {
  const _ReleaseInfo({
    required this.tagName,
    required this.title,
    required this.body,
    required this.htmlUrl,
  });

  final String tagName;
  final String title;
  final String body;
  final String htmlUrl;
}

class _ParsedVersion implements Comparable<_ParsedVersion> {
  const _ParsedVersion._(this.segments, this.displayValue);

  static _ParsedVersion? tryParse(String rawValue) {
    String normalized = rawValue.trim();
    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.startsWith('v') || normalized.startsWith('V')) {
      normalized = normalized.substring(1);
    }

    normalized = normalized.split('+').first.split('-').first.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final List<String> parts = normalized.split('.');
    if (parts.isEmpty) {
      return null;
    }

    final List<int> segments = <int>[];
    for (final String part in parts) {
      final int? value = int.tryParse(part);
      if (value == null) {
        return null;
      }
      segments.add(value);
    }

    return _ParsedVersion._(segments, normalized);
  }

  final List<int> segments;
  final String displayValue;

  @override
  int compareTo(_ParsedVersion other) {
    final int length = segments.length > other.segments.length
        ? segments.length
        : other.segments.length;

    for (int index = 0; index < length; index++) {
      final int left = index < segments.length ? segments[index] : 0;
      final int right = index < other.segments.length
          ? other.segments[index]
          : 0;
      if (left != right) {
        return left.compareTo(right);
      }
    }

    return 0;
  }
}
