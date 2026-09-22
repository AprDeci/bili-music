// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_sms_login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiliSmsLoginController)
final biliSmsLoginControllerProvider = BiliSmsLoginControllerProvider._();

final class BiliSmsLoginControllerProvider
    extends $NotifierProvider<BiliSmsLoginController, BiliSmsLoginState> {
  BiliSmsLoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliSmsLoginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliSmsLoginControllerHash();

  @$internal
  @override
  BiliSmsLoginController create() => BiliSmsLoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliSmsLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliSmsLoginState>(value),
    );
  }
}

String _$biliSmsLoginControllerHash() =>
    r'25343e16bb3454ebab28935d6c47437b2e4801a4';

abstract class _$BiliSmsLoginController extends $Notifier<BiliSmsLoginState> {
  BiliSmsLoginState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BiliSmsLoginState, BiliSmsLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BiliSmsLoginState, BiliSmsLoginState>,
              BiliSmsLoginState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
