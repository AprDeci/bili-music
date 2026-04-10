// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_transfer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesTransferRepository)
final favoritesTransferRepositoryProvider =
    FavoritesTransferRepositoryProvider._();

final class FavoritesTransferRepositoryProvider
    extends
        $FunctionalProvider<
          FavoritesTransferRepository,
          FavoritesTransferRepository,
          FavoritesTransferRepository
        >
    with $Provider<FavoritesTransferRepository> {
  FavoritesTransferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesTransferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesTransferRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoritesTransferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesTransferRepository create(Ref ref) {
    return favoritesTransferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesTransferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesTransferRepository>(value),
    );
  }
}

String _$favoritesTransferRepositoryHash() =>
    r'd7f0353d0dcee05297edfeadbff77d259323dac1';
