// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transfer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appTransferRepository)
final appTransferRepositoryProvider = AppTransferRepositoryProvider._();

final class AppTransferRepositoryProvider
    extends
        $FunctionalProvider<
          AppTransferRepository,
          AppTransferRepository,
          AppTransferRepository
        >
    with $Provider<AppTransferRepository> {
  AppTransferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appTransferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appTransferRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppTransferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppTransferRepository create(Ref ref) {
    return appTransferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTransferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTransferRepository>(value),
    );
  }
}

String _$appTransferRepositoryHash() =>
    r'21bf599101d1218d579c83d45f036d26caa7298c';
