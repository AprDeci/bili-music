import 'dart:async';
import 'dart:io';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/updater/data/update_notification.dart';
import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:bilimusic/feature/updater/domain/updater_state.dart';
import 'package:open_filex/open_filex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'updater_controller.g.dart';

@riverpod
UpdateRepository updateRepository(Ref ref) => UpdateRepository();

@Riverpod(keepAlive: true)
class UpdaterController extends _$UpdaterController {
  static const Duration _reportInterval = Duration(milliseconds: 500);

  final AppLogger _logger = AppLogger('UpdaterController');

  DateTime _lastReportAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastReportPercent = -1;
  bool? _notificationsAvailable;

  @override
  UpdaterState build() => const UpdaterState();

  /// 探测镜像、后台下载、校验并在完成后调起系统安装器。
  Future<void> downloadAndInstall(UpdateAsset asset) async {
    if (state.isBusy) {
      return;
    }

    final UpdateRepository repository = ref.read(updateRepositoryProvider);
    final List<String> candidates = UpdateRepository.buildDownloadCandidates(
      asset.downloadUrl,
    );

    try {
      state = const UpdaterState(phase: UpdatePhase.probing);
      final List<String> ordered = await repository.orderCandidatesByLatency(
        candidates,
        expectedBytes: asset.sizeBytes,
      );

      state = UpdaterState(
        phase: UpdatePhase.downloading,
        totalBytes: asset.sizeBytes,
      );
      final File file = await repository.downloadApk(
        asset: asset,
        candidates: ordered,
        onMirrorSelected: _notifyMirrorSelected,
        onProgress: _notifyProgress,
      );

      state = const UpdaterState(phase: UpdatePhase.installing);
      await _finish('下载完成，正在调起安装');
      await UpdateNotification.cancel();
      final OpenResult result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw UpdateDownloadException(
          result.message.isEmpty ? '无法调起安装器' : result.message,
        );
      }

      ToastUtil.show('如未出现安装界面，请先允许本应用「安装未知应用」');
      state = const UpdaterState();
    } on Object catch (error) {
      final String message = error is UpdateDownloadException
          ? error.message
          : '更新失败：$error';
      _logger.e('downloadAndInstall failed', error);
      state = const UpdaterState();
      await _finish(message);
      await UpdateNotification.showFailure(message);
    }
  }

  /// 收尾提示：先关掉兜底的进度 toast，再给一次性结果提示。
  Future<void> _finish(String message) async {
    await ToastUtil.dismissProgress();
    ToastUtil.show(message);
  }

  void _notifyMirrorSelected(String url) {
    final String host = Uri.tryParse(url)?.host ?? url;
    state = state.copyWith(mirrorHost: host);
    // 换线路后重新计数，让新线路的首个进度立刻可见。
    _resetProgressThrottle();
    unawaited(_prepareNotifications());
  }

  /// 申请通知权限并记下通知是否可用；不可用时退回应用内进度 toast。
  Future<void> _prepareNotifications() async {
    _notificationsAvailable = await UpdateNotification.prepare();
  }

  void _notifyProgress(int received, int total) {
    final int effectiveTotal = total > 0 ? total : state.totalBytes;
    if (effectiveTotal <= 0) {
      return;
    }

    final int percent = (received * 100 ~/ effectiveTotal).clamp(0, 100);
    final DateTime now = DateTime.now();
    final bool isFirstReport = _lastReportPercent < 0;
    final bool percentChanged = percent != _lastReportPercent;
    final bool intervalElapsed =
        now.difference(_lastReportAt) >= _reportInterval;
    if (!isFirstReport && (!percentChanged || !intervalElapsed)) {
      return;
    }

    _lastReportAt = now;
    _lastReportPercent = percent;
    final String? host = state.mirrorHost;
    if (_notificationsAvailable == false) {
      final String label = percent <= 0 ? '开始下载' : '正在下载更新 $percent%';
      ToastUtil.showProgress(host == null ? label : '$label（$host）');
    }
    unawaited(UpdateNotification.showProgress(percent: percent, host: host));
  }

  void _resetProgressThrottle() {
    _lastReportAt = DateTime.fromMillisecondsSinceEpoch(0);
    _lastReportPercent = -1;
  }
}
