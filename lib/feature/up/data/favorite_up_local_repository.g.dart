// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_up_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteUpLocalRepository)
final favoriteUpLocalRepositoryProvider = FavoriteUpLocalRepositoryProvider._();

final class FavoriteUpLocalRepositoryProvider
    extends
        $FunctionalProvider<
          FavoriteUpLocalRepository,
          FavoriteUpLocalRepository,
          FavoriteUpLocalRepository
        >
    with $Provider<FavoriteUpLocalRepository> {
  FavoriteUpLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteUpLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteUpLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoriteUpLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoriteUpLocalRepository create(Ref ref) {
    return favoriteUpLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteUpLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteUpLocalRepository>(value),
    );
  }
}

String _$favoriteUpLocalRepositoryHash() =>
    r'e1160f4d711a75394e7b994ec97fc5ac974c7dfe';
