import 'package:bilimusic/core/bili/session/bili_session.dart';

enum BiliQrLoginStatus {
  initial,
  loading,
  waitingForScan,
  waitingForConfirm,
  success,
  expired,
  failure,
}

class BiliQrCodeSession {
  const BiliQrCodeSession({
    required this.url,
    required this.qrcodeKey,
  });

  final String url;
  final String qrcodeKey;
}

class BiliAuthState {
  const BiliAuthState({
    this.status = BiliQrLoginStatus.initial,
    this.qrSession,
    this.session,
    this.message,
    this.lastPollCode,
  });

  final BiliQrLoginStatus status;
  final BiliQrCodeSession? qrSession;
  final BiliSession? session;
  final String? message;
  final int? lastPollCode;

  bool get isBusy =>
      status == BiliQrLoginStatus.loading ||
      status == BiliQrLoginStatus.waitingForScan ||
      status == BiliQrLoginStatus.waitingForConfirm;

  BiliAuthState copyWith({
    BiliQrLoginStatus? status,
    BiliQrCodeSession? qrSession,
    bool clearQrSession = false,
    BiliSession? session,
    bool clearSession = false,
    String? message,
    bool clearMessage = false,
    int? lastPollCode,
    bool clearLastPollCode = false,
  }) {
    return BiliAuthState(
      status: status ?? this.status,
      qrSession: clearQrSession ? null : (qrSession ?? this.qrSession),
      session: clearSession ? null : (session ?? this.session),
      message: clearMessage ? null : (message ?? this.message),
      lastPollCode:
          clearLastPollCode ? null : (lastPollCode ?? this.lastPollCode),
    );
  }
}
