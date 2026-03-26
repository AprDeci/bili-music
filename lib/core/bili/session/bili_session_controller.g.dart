// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiliSessionController)
final biliSessionControllerProvider = BiliSessionControllerProvider._();

final class BiliSessionControllerProvider
    extends $NotifierProvider<BiliSessionController, BiliSession?> {
  BiliSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliSessionControllerHash();

  @$internal
  @override
  BiliSessionController create() => BiliSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliSession?>(value),
    );
  }
}

String _$biliSessionControllerHash() =>
    r'be8c52159d0cff2969e5511bd610fe40a7c2dcf5';

abstract class _$BiliSessionController extends $Notifier<BiliSession?> {
  BiliSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BiliSession?, BiliSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BiliSession?, BiliSession?>,
              BiliSession?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
