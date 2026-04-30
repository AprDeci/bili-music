// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transfer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appTransferController)
final appTransferControllerProvider = AppTransferControllerProvider._();

final class AppTransferControllerProvider
    extends
        $FunctionalProvider<
          AppTransferController,
          AppTransferController,
          AppTransferController
        >
    with $Provider<AppTransferController> {
  AppTransferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appTransferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appTransferControllerHash();

  @$internal
  @override
  $ProviderElement<AppTransferController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppTransferController create(Ref ref) {
    return appTransferController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTransferController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTransferController>(value),
    );
  }
}

String _$appTransferControllerHash() =>
    r'1343786e5d3839dfc592c6b8a596b3d9a8f14434';
