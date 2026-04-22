import 'dart:convert';
import 'dart:typed_data';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/common/components/url_text_input.dart';
import 'package:bilimusic/feature/setting/domain/webdav_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

part 'webdav_repository.g.dart';

@riverpod
WebDavRepository webDavRepository(Ref ref) {
  return WebDavRepository(settingsStore: ref.read(appSettingsStoreProvider));
}

class WebDavRepository {
  static const String _remoteDir = '/bilimusic';

  WebDavRepository({required AppSettingsStore settingsStore})
    : _settingsStore = settingsStore;

  final AppSettingsStore _settingsStore;

  WebDavConfig loadConfig() {
    return WebDavConfig(
      baseUrl: _settingsStore.readString(
        HiveKeys.webDavBaseUrl,
        defaultValue: '',
      ),
      username: _settingsStore.readString(
        HiveKeys.webDavUsername,
        defaultValue: '',
      ),
      password: _settingsStore.readString(
        HiveKeys.webDavPassword,
        defaultValue: '',
      ),
    );
  }

  Future<void> saveConfig(WebDavConfig config) async {
    final WebDavConfig normalized = _normalizeConfig(config);
    await Future.wait(<Future<void>>[
      _settingsStore.writeString(HiveKeys.webDavBaseUrl, normalized.baseUrl),
      _settingsStore.writeString(HiveKeys.webDavUsername, normalized.username),
      _settingsStore.writeString(HiveKeys.webDavPassword, normalized.password),
    ]);
  }

  Future<void> testConnection() async {
    final webdav.Client client = _buildClient();
    try {
      await client.ping();
      await client.mkdirAll(_remoteDir);
    } on Object catch (error) {
      throw WebDavException(_describeError(error, fallback: 'WebDAV 连接失败。'));
    }
  }

  Future<List<WebDavBackupItem>> listBackupFiles() async {
    final webdav.Client client = _buildClient();
    try {
      await client.mkdirAll(_remoteDir);
      final List<webdav.File> files = await client.readDir(_remoteDir);
      final List<WebDavBackupItem> backups =
          files
              .where((webdav.File file) => file.isDir != true)
              .where((webdav.File file) => (file.name ?? '').endsWith('.json'))
              .map((webdav.File file) {
                final String path =
                    file.path ?? '$_remoteDir/${file.name ?? ''}';
                final String name = file.name ?? path.split('/').last;
                return WebDavBackupItem(
                  remotePath: path,
                  name: name,
                  size: file.size ?? 0,
                  modifiedAt: file.mTime,
                );
              })
              .toList(growable: false)
            ..sort((WebDavBackupItem a, WebDavBackupItem b) {
              final DateTime left =
                  a.modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final DateTime right =
                  b.modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return right.compareTo(left);
            });
      return backups;
    } on Object catch (error) {
      throw WebDavException(
        _describeError(error, fallback: '读取 WebDAV 备份列表失败。'),
      );
    }
  }

  Future<void> uploadFavoritesBackup(String json, String fileName) async {
    final webdav.Client client = _buildClient();
    final String remotePath = _joinRemotePath(_remoteDir, fileName);
    try {
      await client.mkdirAll(_remoteDir);
      await client.write(remotePath, Uint8List.fromList(utf8.encode(json)));
    } on Object catch (error) {
      throw WebDavException(_describeError(error, fallback: '上传 WebDAV 备份失败。'));
    }
  }

  Future<Uint8List> downloadBackupBytes(String remotePath) async {
    final webdav.Client client = _buildClient();
    try {
      final List<int> bytes = await client.read(remotePath);
      return Uint8List.fromList(bytes);
    } on Object catch (error) {
      throw WebDavException(_describeError(error, fallback: '下载 WebDAV 备份失败。'));
    }
  }

  Future<void> deleteBackup(String remotePath) async {
    final webdav.Client client = _buildClient();
    try {
      await client.remove(remotePath);
    } on Object catch (error) {
      throw WebDavException(_describeError(error, fallback: '删除 WebDAV 备份失败。'));
    }
  }

  webdav.Client _buildClient() {
    final WebDavConfig config = _normalizeConfig(loadConfig());
    if (!config.isConfigured) {
      throw const WebDavException('请先填写完整的 WebDAV 地址、用户名和密码。');
    }
    final webdav.Client client = webdav.newClient(
      config.baseUrl,
      user: config.username,
      password: config.password,
    );
    client.setConnectTimeout(10000);
    client.setSendTimeout(15000);
    client.setReceiveTimeout(15000);
    return client;
  }

  WebDavConfig _normalizeConfig(WebDavConfig config) {
    return config.copyWith(
      baseUrl: normalizeHttpUrl(config.baseUrl),
      username: config.username.trim(),
      password: config.password,
    );
  }

  String _joinRemotePath(String dir, String fileName) {
    final String normalizedName = fileName.trim();
    if (normalizedName.isEmpty) {
      throw const WebDavException('备份文件名不能为空。');
    }
    return '$dir/$normalizedName';
  }

  String _describeError(Object error, {required String fallback}) {
    final String message = error.toString().trim();
    if (message.isEmpty) {
      return fallback;
    }
    return message;
  }
}

class WebDavBackupItem {
  const WebDavBackupItem({
    required this.remotePath,
    required this.name,
    required this.size,
    required this.modifiedAt,
  });

  final String remotePath;
  final String name;
  final int size;
  final DateTime? modifiedAt;
}

class WebDavException implements Exception {
  const WebDavException(this.message);

  final String message;

  @override
  String toString() => message;
}
