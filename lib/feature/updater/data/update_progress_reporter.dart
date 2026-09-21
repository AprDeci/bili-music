import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/updater/data/update_notification.dart';
import 'package:window_manager/window_manager.dart';

/// 下载进度的展示通道。
///
/// - Android：通知栏（权限被拒时退回应用内 toast）。
/// - Windows：任务栏进度条 + 窗口标题百分比。
/// - 其他：应用内进度 toast。
///
/// 任何通道失败都只记日志，不影响下载流程。
class UpdateProgressReporter {
  bool _prepared = false;
  bool _useNotification = false;
  bool _useTaskbar = false;
  String? _restoreTitle;

  final AppLogger _logger = AppLogger('UpdateProgressReporter');

  Future<void> prepare() async {
    if (_prepared) {
      return;
    }
    _prepared = true;

    if (PlatformUtil.isAndroid) {
      _useNotification = await UpdateNotification.prepare();
      return;
    }
    if (!PlatformUtil.isWindows) {
      return;
    }

    _useTaskbar = true;
    try {
      _restoreTitle = await windowManager.getTitle();
    } on Object catch (error) {
      _logger.w('read window title failed: $error');
    }
  }

  Future<void> report(int percent, String? host) async {
    if (_useNotification) {
      await UpdateNotification.showProgress(percent: percent, host: host);
      return;
    }
    if (_useTaskbar) {
      await _reportOnTaskbar(percent, host);
      return;
    }

    final String label = percent <= 0 ? '开始下载' : '正在下载更新 $percent%';
    ToastUtil.showProgress(host == null ? label : '$label（$host）');
  }

  Future<void> finish() async {
    if (_useNotification) {
      await UpdateNotification.cancel();
      return;
    }
    await _clearTaskbar();
  }

  Future<void> fail(String message) async {
    if (_useNotification) {
      await UpdateNotification.showFailure(message);
      return;
    }
    await _clearTaskbar();
  }

  Future<void> _reportOnTaskbar(int percent, String? host) async {
    try {
      await windowManager.setProgressBar(percent.clamp(0, 100) / 100);
      final String suffix = host == null || host.isEmpty
          ? '$percent%'
          : '$percent%（$host）';
      await windowManager.setTitle('bilimusic · 正在下载更新 $suffix');
    } on Object catch (error) {
      _logger.w('report taskbar progress failed: $error');
    }
  }

  Future<void> _clearTaskbar() async {
    if (!_useTaskbar) {
      return;
    }
    _useTaskbar = false;
    try {
      await windowManager.setProgressBar(-1);
      final String? title = _restoreTitle;
      if (title != null) {
        await windowManager.setTitle(title);
      }
      _restoreTitle = null;
    } on Object catch (error) {
      _logger.w('clear taskbar progress failed: $error');
    }
  }
}
