// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliAuthRepository)
final biliAuthRepositoryProvider = BiliAuthRepositoryProvider._();

final class BiliAuthRepositoryProvider
    extends
        $FunctionalProvider<
          BiliAuthRepository,
          BiliAuthRepository,
          BiliAuthRepository
        >
    with $Provider<BiliAuthRepository> {
  BiliAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliAuthRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliAuthRepository create(Ref ref) {
    return biliAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliAuthRepository>(value),
    );
  }
}

String _$biliAuthRepositoryHash() =>
    r'eb42b04bb836a382138c5b55baf7348bdb64b33e';

@ProviderFor(BiliAuthController)
final biliAuthControllerProvider = BiliAuthControllerProvider._();

final class BiliAuthControllerProvider
    extends $NotifierProvider<BiliAuthController, BiliAuthState> {
  BiliAuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliAuthControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliAuthControllerHash();

  @$internal
  @override
  BiliAuthController create() => BiliAuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliAuthState>(value),
    );
  }
}

String _$biliAuthControllerHash() =>
    r'83d8e781749f9e2e8ee59b0b5306862f43281d5d';

abstract class _$BiliAuthController extends $Notifier<BiliAuthState> {
  BiliAuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BiliAuthState, BiliAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BiliAuthState, BiliAuthState>,
              BiliAuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
