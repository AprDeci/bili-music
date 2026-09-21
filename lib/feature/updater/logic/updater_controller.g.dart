// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updater_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateRepository)
final updateRepositoryProvider = UpdateRepositoryProvider._();

final class UpdateRepositoryProvider
    extends
        $FunctionalProvider<
          UpdateRepository,
          UpdateRepository,
          UpdateRepository
        >
    with $Provider<UpdateRepository> {
  UpdateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateRepositoryHash();

  @$internal
  @override
  $ProviderElement<UpdateRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateRepository create(Ref ref) {
    return updateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateRepository>(value),
    );
  }
}

String _$updateRepositoryHash() => r'05b71cb2350adba654aaa331de6db3af4e82d6f4';

@ProviderFor(UpdaterController)
final updaterControllerProvider = UpdaterControllerProvider._();

final class UpdaterControllerProvider
    extends $NotifierProvider<UpdaterController, UpdaterState> {
  UpdaterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updaterControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updaterControllerHash();

  @$internal
  @override
  UpdaterController create() => UpdaterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdaterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdaterState>(value),
    );
  }
}

String _$updaterControllerHash() => r'6b1a6812c3ecdf67522c9de96f0051c839b43c59';

abstract class _$UpdaterController extends $Notifier<UpdaterState> {
  UpdaterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UpdaterState, UpdaterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdaterState, UpdaterState>,
              UpdaterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
