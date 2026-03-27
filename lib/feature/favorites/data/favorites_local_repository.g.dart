// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesLocalRepository)
final favoritesLocalRepositoryProvider = FavoritesLocalRepositoryProvider._();

final class FavoritesLocalRepositoryProvider
    extends
        $FunctionalProvider<
          FavoritesLocalRepository,
          FavoritesLocalRepository,
          FavoritesLocalRepository
        >
    with $Provider<FavoritesLocalRepository> {
  FavoritesLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoritesLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesLocalRepository create(Ref ref) {
    return favoritesLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesLocalRepository>(value),
    );
  }
}

String _$favoritesLocalRepositoryHash() =>
    r'cc9af401af7b1959d17a56eee88902850aa37279';
