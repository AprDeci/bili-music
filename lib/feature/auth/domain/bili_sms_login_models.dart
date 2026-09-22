import 'package:freezed_annotation/freezed_annotation.dart';

part 'bili_sms_login_models.freezed.dart';

enum BiliSmsLoginStatus {
  idle,
  requestingCaptcha,
  awaitingCaptcha,
  sendingCode,
  codeSent,
  submitting,
  success,
  failure,
}

@freezed
abstract class BiliSmsLoginState with _$BiliSmsLoginState {
  const factory BiliSmsLoginState({
    @Default(BiliSmsLoginStatus.idle) BiliSmsLoginStatus status,
    @Default('') String tel,
    BiliCaptchaParams? captcha,
    String? captchaKey,
    @Default(0) int countdownSeconds,
    String? message,
  }) = _BiliSmsLoginState;

  const BiliSmsLoginState._();

  bool get isBusy =>
      status == BiliSmsLoginStatus.requestingCaptcha ||
      status == BiliSmsLoginStatus.awaitingCaptcha ||
      status == BiliSmsLoginStatus.sendingCode ||
      status == BiliSmsLoginStatus.submitting;

  bool get hasCaptchaKey => (captchaKey?.isNotEmpty ?? false);
}

/// 申请 captcha 验证码接口返回的极验参数。
@freezed
abstract class BiliCaptchaParams with _$BiliCaptchaParams {
  const factory BiliCaptchaParams({
    required String token,
    required String gt,
    required String challenge,
  }) = _BiliCaptchaParams;
}

/// 极验验证成功后回传的结果，用于短信发送接口。
@freezed
abstract class BiliGeetestResult with _$BiliGeetestResult {
  const factory BiliGeetestResult({
    required String challenge,
    required String validate,
    required String seccode,
  }) = _BiliGeetestResult;
}
