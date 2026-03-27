// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesController)
final favoritesControllerProvider = FavoritesControllerProvider._();

final class FavoritesControllerProvider
    extends $NotifierProvider<FavoritesController, FavoritesState> {
  FavoritesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesControllerHash();

  @$internal
  @override
  FavoritesController create() => FavoritesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesState>(value),
    );
  }
}

String _$favoritesControllerHash() =>
    r'3ef4b2e238c95abeb40cbbc4c04fa80e778924e9';

abstract class _$FavoritesController extends $Notifier<FavoritesState> {
  FavoritesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoritesState, FavoritesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoritesState, FavoritesState>,
              FavoritesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
