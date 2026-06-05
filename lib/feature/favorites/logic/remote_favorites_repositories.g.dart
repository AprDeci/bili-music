// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_favorites_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesRemoteCacheRepository)
final favoritesRemoteCacheRepositoryProvider =
    FavoritesRemoteCacheRepositoryProvider._();

final class FavoritesRemoteCacheRepositoryProvider
    extends
        $FunctionalProvider<
          FavoritesRemoteCacheRepository,
          FavoritesRemoteCacheRepository,
          FavoritesRemoteCacheRepository
        >
    with $Provider<FavoritesRemoteCacheRepository> {
  FavoritesRemoteCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesRemoteCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesRemoteCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoritesRemoteCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesRemoteCacheRepository create(Ref ref) {
    return favoritesRemoteCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesRemoteCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesRemoteCacheRepository>(
        value,
      ),
    );
  }
}

String _$favoritesRemoteCacheRepositoryHash() =>
    r'd221a5555da29fbe5885e6a60a9a1fca63f417a9';

@ProviderFor(biliFavoritesRemoteRepository)
final biliFavoritesRemoteRepositoryProvider =
    BiliFavoritesRemoteRepositoryProvider._();

final class BiliFavoritesRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          BiliFavoritesRemoteRepository,
          BiliFavoritesRemoteRepository,
          BiliFavoritesRemoteRepository
        >
    with $Provider<BiliFavoritesRemoteRepository> {
  BiliFavoritesRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliFavoritesRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliFavoritesRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliFavoritesRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliFavoritesRemoteRepository create(Ref ref) {
    return biliFavoritesRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliFavoritesRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliFavoritesRemoteRepository>(
        value,
      ),
    );
  }
}

String _$biliFavoritesRemoteRepositoryHash() =>
    r'64e9fd66c18f775b2f585ee5f9b9c406bc51b04f';
