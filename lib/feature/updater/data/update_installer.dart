import 'dart:io';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/window/desktop_app_lifecycle.dart';
import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:open_filex/open_filex.dart';

// 调起平台安装程序。
class UpdateInstaller {
  UpdateInstaller._();

  static const Duration _exitDelay = Duration(milliseconds: 800);

  static final AppLogger _logger = AppLogger('UpdateInstaller');

  static Future<void> install(File file) async {
    if (PlatformUtil.isAndroid) {
      await _installOnAndroid(file);
      return;
    }
    if (PlatformUtil.isWindows) {
      await _installOnWindows(file);
      return;
    }
    throw const UpdateDownloadException('当前平台不支持应用内安装');
  }

  static Future<void> _installOnAndroid(File file) async {
    final OpenResult result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw UpdateDownloadException(
        result.message.isEmpty ? '无法调起安装器' : result.message,
      );
    }
    ToastUtil.show('如未出现安装界面，请先允许本应用「安装未知应用」');
  }

  static Future<void> _installOnWindows(File file) async {
    final Process process = await Process.start(file.path, const <String>[
      '/CLOSEAPPLICATIONS',
      '/RESTARTAPPLICATIONS',
    ], mode: ProcessStartMode.detached);
    _logger.d('installer started, pid: ${process.pid}');

    // 等安装器起来再退出，避免它还没加载完应用就没了。
    await Future<void>.delayed(_exitDelay);
    await DesktopAppLifecycle.current?.requestExit();
  }
}
