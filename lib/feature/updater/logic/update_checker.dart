import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/updater/data/update_dismissed_store.dart';
import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:bilimusic/feature/updater/domain/update_version.dart';
import 'package:bilimusic/feature/updater/logic/updater_controller.dart';
import 'package:bilimusic/feature/updater/ui/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 检查更新：拉最新 release → 版本比较 → 弹窗 → Android 走应用内下载安装，其他平台打开 release 页。
class UpdateChecker {
  UpdateChecker._();

  static final AppLogger _logger = AppLogger('UpdateChecker');
  static const UpdateDismissedStore _dismissedStore = UpdateDismissedStore();

  static Future<void> checkAndPrompt(
    BuildContext context, {
    bool manual = false,
  }) async {
    _logger.d('checkAndPrompt manual: $manual');
    if (!context.mounted) {
      return;
    }

    final ProviderContainer container = ProviderScope.containerOf(
      context,
      listen: false,
    );

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final UpdateVersion? currentVersion = UpdateVersion.tryParse(
        packageInfo.version,
      );
      if (currentVersion == null) {
        _toastIfManual(manual, '检查更新失败');
        return;
      }

      final UpdateRelease release = await container
          .read(updateRepositoryProvider)
          .fetchLatestRelease();
      final UpdateVersion? latestVersion = UpdateVersion.tryParse(
        release.tagName,
      );
      if (latestVersion == null) {
        _toastIfManual(manual, '检查更新失败');
        return;
      }

      if (latestVersion.compareTo(currentVersion) <= 0) {
        _toastIfManual(manual, '当前已是最新版本');
        return;
      }

      final String? dismissedTag = _dismissedStore.load();
      if (!manual && dismissedTag == release.tagName) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      final UpdateAsset? apkAsset = _resolveAndroidAsset(release);
      final UpdateDialogAction? action = await showUpdateDialog(
        context,
        currentVersion: currentVersion.displayValue,
        latestVersion: latestVersion.displayValue,
        release: release,
        apkAsset: apkAsset,
      );
      if (!context.mounted || action == null) {
        return;
      }

      await _dismissedStore.save(release.tagName);

      switch (action) {
        case UpdateDialogAction.later:
          break;
        case UpdateDialogAction.openReleasePage:
          await launchUrl(
            Uri.parse(release.htmlUrl),
            mode: LaunchMode.externalApplication,
          );
        case UpdateDialogAction.downloadAndInstall:
          if (apkAsset != null) {
            await container
                .read(updaterControllerProvider.notifier)
                .downloadAndInstall(apkAsset);
          }
      }
    } on Object catch (error, stackTrace) {
      _logger.e('checkAndPrompt failed', error, stackTrace);
      _toastIfManual(manual, '检查更新失败');
    }
  }

  static UpdateAsset? _resolveAndroidAsset(UpdateRelease release) {
    if (!PlatformUtil.isAndroid) {
      return null;
    }
    return release.selectApkAsset(UpdateRepository.abiSuffixCandidates());
  }

  static void _toastIfManual(bool manual, String message) {
    if (manual) {
      ToastUtil.show(message);
    }
  }
}
