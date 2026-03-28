import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_auth_controller.g.dart';

@riverpod
BiliAuthRepository biliAuthRepository(Ref ref) {
  return BiliAuthRepository(ref.read(biliClientProvider.notifier));
}

@riverpod
class BiliAuthController extends _$BiliAuthController {
  late final BiliAuthRepository _repository = ref.read(
    biliAuthRepositoryProvider,
  );
  Timer? _pollTimer;
  bool _isPolling = false;

  @override
  BiliAuthState build() {
    ref.onDispose(_cancelPolling);

    final BiliSession? savedSession = ref.read(biliSessionControllerProvider);
    if (savedSession != null && savedSession.isReady) {
      return BiliAuthState(
        status: BiliQrLoginStatus.success,
        session: savedSession,
      );
    }

    return const BiliAuthState();
  }

  Future<void> startQrLogin() async {
    _cancelPolling();
    state = state.copyWith(
      status: BiliQrLoginStatus.loading,
      qrSession: null,
      message: null,
      lastPollCode: null,
    );

    try {
      final BiliQrCodeSession qrSession = await _repository.generateQrCode();
      state = state.copyWith(
        status: BiliQrLoginStatus.waitingForScan,
        qrSession: qrSession,
      );

      _pollTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _pollQrCode(),
      );
      await _pollQrCode();
    } on Object catch (error) {
      state = state.copyWith(
        status: BiliQrLoginStatus.failure,
        message: error.toString(),
      );
    }
  }

  Future<void> restartQrLogin() => startQrLogin();

  Future<LogoutResult> logout() async {
    _cancelPolling();
    final BiliSession? currentSession = ref.read(biliSessionControllerProvider);
    final BiliSessionController sessionController = ref.read(
      biliSessionControllerProvider.notifier,
    );
    final LogoutResult result = currentSession == null
        ? const LogoutResult(
            remoteLoggedOut: false,
            message: '当前没有已登录账号',
          )
        : await _repository.logout(currentSession);
    await sessionController.clearSession();
    if (!ref.mounted) {
      return result;
    }
    state = const BiliAuthState();
    return result;
  }

  Future<void> _pollQrCode() async {
    final BiliQrCodeSession? qrSession = state.qrSession;
    if (_isPolling || qrSession == null) {
      return;
    }

    _isPolling = true;
    try {
      final PollQrCodeResult result = await _repository.pollQrCode(
        qrSession.qrcodeKey,
      );

      switch (result.code) {
        case 0:
          _cancelPolling();
          final BiliSessionController sessionController = ref.read(
            biliSessionControllerProvider.notifier,
          );
          await sessionController.adoptAuthenticatedSession(result.session!);
          final BiliSession enrichedSession =
              await sessionController.refreshSessionFromNav();
          state = state.copyWith(
            status: BiliQrLoginStatus.success,
            session: enrichedSession,
            message: '登录成功',
            lastPollCode: result.code,
          );
          return;
        case 86090:
          state = state.copyWith(
            status: BiliQrLoginStatus.waitingForConfirm,
            message: '已扫码，请在 B 站 App 中确认登录',
            lastPollCode: result.code,
          );
          return;
        case 86101:
          state = state.copyWith(
            status: BiliQrLoginStatus.waitingForScan,
            message: '请使用 B 站 App 扫码登录',
            lastPollCode: result.code,
          );
          return;
        case 86038:
          _cancelPolling();
          state = state.copyWith(
            status: BiliQrLoginStatus.expired,
            message: '二维码已失效，请重新获取',
            lastPollCode: result.code,
          );
          return;
        default:
          _cancelPolling();
          state = state.copyWith(
            status: BiliQrLoginStatus.failure,
            message: result.message,
            lastPollCode: result.code,
          );
          return;
      }
    } on Object catch (error) {
      _cancelPolling();
      state = state.copyWith(
        status: BiliQrLoginStatus.failure,
        message: error.toString(),
      );
    } finally {
      _isPolling = false;
    }
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
