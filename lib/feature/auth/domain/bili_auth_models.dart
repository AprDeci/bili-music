import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bili_auth_models.freezed.dart';

enum BiliQrLoginStatus {
  initial,
  loading,
  waitingForScan,
  waitingForConfirm,
  success,
  expired,
  failure,
}

@freezed
abstract class BiliQrCodeSession with _$BiliQrCodeSession {
  const factory BiliQrCodeSession({
    required String url,
    required String qrcodeKey,
  }) = _BiliQrCodeSession;
}

@freezed
abstract class BiliAuthState with _$BiliAuthState {
  const factory BiliAuthState({
    @Default(BiliQrLoginStatus.initial) BiliQrLoginStatus status,
    BiliQrCodeSession? qrSession,
    BiliSession? session,
    String? message,
    int? lastPollCode,
  }) = _BiliAuthState;

  const BiliAuthState._();

  bool get isBusy =>
      status == BiliQrLoginStatus.loading ||
      status == BiliQrLoginStatus.waitingForScan ||
      status == BiliQrLoginStatus.waitingForConfirm;
}
