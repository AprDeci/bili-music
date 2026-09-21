import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 下载进度/结果通知，只在 Android 上生效。
///
/// 通知只是补充信息，任何失败都静默降级，绝不影响下载流程本身。
class UpdateNotification {
  UpdateNotification._();

  static const int _notificationId = 1001;
  static const String _channelId = 'app_update';
  static const String _channelName = '应用更新';
  static const String _channelDescription = '应用内下载安装包的进度与结果';
  static const String _iconName = 'ic_stat_update';

  static final AppLogger _logger = AppLogger('UpdateNotification');
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _permissionRequested = false;
  static Future<bool>? _initializing;

  /// 申请权限并返回通知是否真的能显示；false 时调用方应退回应用内提示。
  static Future<bool> prepare() async {
    if (!PlatformUtil.isAndroid) {
      return false;
    }
    if (!await _ensureInitialized()) {
      return false;
    }

    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return false;
      }
      if (!_permissionRequested) {
        _permissionRequested = true;
        await android.requestNotificationsPermission();
      }
      return await android.areNotificationsEnabled() ?? false;
    } on Object catch (error) {
      _logger.w('prepare failed: $error');
      return false;
    }
  }

  static Future<void> showProgress({required int percent, String? host}) {
    final String trimmedHost = host?.trim() ?? '';
    final String body = trimmedHost.isEmpty
        ? '$percent%'
        : '$percent%（$trimmedHost）';
    return _show(
      title: '正在下载更新',
      body: body,
      ongoing: true,
      showProgressBar: true,
      progress: percent,
    );
  }

  static Future<void> showFailure(String message) {
    return _show(
      title: '更新失败',
      body: message,
      ongoing: false,
      showProgressBar: false,
      progress: 0,
    );
  }

  static Future<void> cancel() async {
    if (!PlatformUtil.isAndroid) {
      return;
    }
    try {
      await _plugin.cancel(id: _notificationId);
    } on Object catch (error) {
      _logger.w('cancel failed: $error');
    }
  }

  static Future<void> _show({
    required String title,
    required String body,
    required bool ongoing,
    required bool showProgressBar,
    required int progress,
  }) async {
    if (!PlatformUtil.isAndroid || !await _ensureInitialized()) {
      return;
    }

    try {
      await _plugin.show(
        id: _notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            icon: _iconName,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: ongoing,
            autoCancel: !ongoing,
            onlyAlertOnce: true,
            showProgress: showProgressBar,
            maxProgress: 100,
            progress: progress.clamp(0, 100),
          ),
        ),
      );
    } on Object catch (error) {
      _logger.w('show failed: $error');
    }
  }

  static Future<bool> _ensureInitialized() {
    if (_initialized) {
      return Future<bool>.value(true);
    }
    return _initializing ??= _initialize();
  }

  static Future<bool> _initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_iconName),
        ),
      );
      _initialized = true;
      return true;
    } on Object catch (error) {
      _logger.w('initialize failed: $error');
      _initializing = null;
      return false;
    }
  }
}
