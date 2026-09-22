import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_sms_login_controller.g.dart';

@riverpod
class BiliSmsLoginController extends _$BiliSmsLoginController {
  static const int _geetestErrorCode = 2406;
  static const int _resendCooldownSeconds = 60;
  static final RegExp _telPattern = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codePattern = RegExp(r'^\d{4,6}$');

  late final BiliAuthRepository _repository = ref.read(
    biliAuthRepositoryProvider,
  );
  Timer? _countdownTimer;
  bool _captchaRetried = false;

  @override
  BiliSmsLoginState build() {
    ref.onDispose(_cancelCountdown);
    return const BiliSmsLoginState();
  }

  /// 第一步：校验手机号并申请极验参数，成功后进入等待人机验证状态。
  Future<void> sendCode(String tel) async {
    final String normalized = _digitsOnly(tel);
    if (!_telPattern.hasMatch(normalized)) {
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        tel: normalized,
        message: '请输入 11 位中国大陆手机号',
      );
      return;
    }

    _cancelCountdown();
    _captchaRetried = false;
    state = BiliSmsLoginState(
      status: BiliSmsLoginStatus.requestingCaptcha,
      tel: normalized,
    );
    await _requestCaptcha();
  }

  /// 极验通过后调用：携带验证结果请求短信验证码。
  Future<void> submitCaptcha(BiliGeetestResult geetest) async {
    final BiliCaptchaParams? captcha = state.captcha;
    if (captcha == null) {
      return;
    }

    state = state.copyWith(
      status: BiliSmsLoginStatus.sendingCode,
      message: '正在发送短信验证码...',
    );

    try {
      final BiliSmsSendResult result = await _repository.sendSmsCode(
        tel: state.tel,
        captcha: captcha,
        geetest: geetest,
      );
      if (!ref.mounted) {
        return;
      }

      if (result.code == 0) {
        state = state.copyWith(
          status: BiliSmsLoginStatus.codeSent,
          captcha: null,
          captchaKey: result.captchaKey,
          message: '验证码已发送，请注意查收',
        );
        _startCountdown();
        return;
      }

      if (result.code == _geetestErrorCode && !_captchaRetried) {
        _captchaRetried = true;
        state = state.copyWith(
          status: BiliSmsLoginStatus.requestingCaptcha,
          captcha: null,
          message: '人机验证未通过，请重新验证',
        );
        await _requestCaptcha();
        return;
      }

      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        captcha: null,
        message: _withCode(
          _sendFailureMessage(result.code, result.message),
          result.code,
        ),
      );
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        captcha: null,
        message: error.toString(),
      );
    }
  }

  void cancelCaptcha() {
    state = state.copyWith(
      status: BiliSmsLoginStatus.idle,
      captcha: null,
      message: '已取消人机验证',
    );
  }

  void failCaptcha(String message) {
    state = state.copyWith(
      status: BiliSmsLoginStatus.failure,
      captcha: null,
      message: message,
    );
  }

  /// 第二步：提交短信验证码，成功后写入登录态。
  Future<void> submitCode(String code) async {
    final String normalized = _digitsOnly(code);
    if (!_codePattern.hasMatch(normalized)) {
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        message: '请输入短信中的验证码',
      );
      return;
    }

    final String? captchaKey = state.captchaKey;
    if (captchaKey == null || captchaKey.isEmpty) {
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        message: '请先获取短信验证码',
      );
      return;
    }

    state = state.copyWith(
      status: BiliSmsLoginStatus.submitting,
      message: '正在登录...',
    );

    try {
      final BiliSmsLoginResult result = await _repository.loginBySmsCode(
        tel: state.tel,
        code: normalized,
        captchaKey: captchaKey,
      );
      if (!ref.mounted) {
        return;
      }

      final BiliSession? session = result.session;
      if (result.code != 0 || session == null) {
        state = state.copyWith(
          status: BiliSmsLoginStatus.failure,
          message: _withCode(
            _loginFailureMessage(result.code, result.message),
            result.code,
          ),
        );
        return;
      }

      final BiliSessionController sessionController = ref.read(
        biliSessionControllerProvider.notifier,
      );
      await sessionController.adoptAuthenticatedSession(session);
      await sessionController.refreshSessionFromNav();
      if (!ref.mounted) {
        return;
      }

      _cancelCountdown();
      state = state.copyWith(
        status: BiliSmsLoginStatus.success,
        message: '登录成功',
      );
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        message: error.toString(),
      );
    }
  }

  Future<void> _requestCaptcha() async {
    try {
      final BiliCaptchaParams params = await _repository.fetchCaptcha();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: BiliSmsLoginStatus.awaitingCaptcha,
        captcha: params,
        message: '请完成人机验证',
      );
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: BiliSmsLoginStatus.failure,
        captcha: null,
        message: error.toString(),
      );
    }
  }

  void _startCountdown() {
    _cancelCountdown();
    state = state.copyWith(countdownSeconds: _resendCooldownSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final int next = state.countdownSeconds - 1;
      if (next <= 0) {
        _cancelCountdown();
        state = state.copyWith(countdownSeconds: 0);
        return;
      }
      state = state.copyWith(countdownSeconds: next);
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// 手机号与验证码都只接受数字，粘贴内容里的空格、横线等一并去掉。
  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// debug 构建下把服务端返回码附在提示后面，便于定位风控类失败。
  String _withCode(String message, int code) =>
      kDebugMode ? '$message（code $code）' : message;

  String _sendFailureMessage(int code, String message) {
    switch (code) {
      case 1002:
        return '手机号格式不正确';
      case 1003:
        return '验证码已发送，请查看短信';
      case 1025:
        return '该手机号存在永久封禁记录，无法登录';
      case 2400:
        return '登录密钥已失效，请重新获取验证码';
      case 86203:
        return '短信发送次数已达上限，请稍后再试';
      case _geetestErrorCode:
        return '人机验证失败，请稍后重试';
      default:
        return message.isNotEmpty ? message : '验证码发送失败（$code）';
    }
  }

  String _loginFailureMessage(int code, String message) {
    switch (code) {
      case 1006:
        return '短信验证码不正确';
      case 1007:
        return '短信验证码已过期，请重新获取';
      case -400:
        return '请求错误，请稍后重试';
      default:
        return message.isNotEmpty ? message : '登录失败（$code）';
    }
  }
}
