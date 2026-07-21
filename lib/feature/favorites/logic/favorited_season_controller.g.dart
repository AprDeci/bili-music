// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorited_season_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritedSeasonLocalRepository)
final favoritedSeasonLocalRepositoryProvider =
    FavoritedSeasonLocalRepositoryProvider._();

final class FavoritedSeasonLocalRepositoryProvider
    extends
        $FunctionalProvider<
          FavoritedSeasonLocalRepository,
          FavoritedSeasonLocalRepository,
          FavoritedSeasonLocalRepository
        >
    with $Provider<FavoritedSeasonLocalRepository> {
  FavoritedSeasonLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritedSeasonLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritedSeasonLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoritedSeasonLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritedSeasonLocalRepository create(Ref ref) {
    return favoritedSeasonLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritedSeasonLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritedSeasonLocalRepository>(
        value,
      ),
    );
  }
}

String _$favoritedSeasonLocalRepositoryHash() =>
    r'c1461420c7fcdddc9d6e9807c759208f665fbc89';

@ProviderFor(FavoritedSeasonController)
final favoritedSeasonControllerProvider = FavoritedSeasonControllerProvider._();

final class FavoritedSeasonControllerProvider
    extends
        $NotifierProvider<FavoritedSeasonController, List<FavoritedSeason>> {
  FavoritedSeasonControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritedSeasonControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritedSeasonControllerHash();

  @$internal
  @override
  FavoritedSeasonController create() => FavoritedSeasonController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FavoritedSeason> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FavoritedSeason>>(value),
    );
  }
}

String _$favoritedSeasonControllerHash() =>
    r'6ce57aa5e08b434082d752fac5d4bf55384a7480';

abstract class _$FavoritedSeasonController
    extends $Notifier<List<FavoritedSeason>> {
  List<FavoritedSeason> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<FavoritedSeason>, List<FavoritedSeason>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<FavoritedSeason>, List<FavoritedSeason>>,
              List<FavoritedSeason>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
