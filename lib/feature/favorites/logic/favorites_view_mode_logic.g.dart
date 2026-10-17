// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_view_mode_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesViewModeLogic)
final favoritesViewModeLogicProvider = FavoritesViewModeLogicProvider._();

final class FavoritesViewModeLogicProvider
    extends $NotifierProvider<FavoritesViewModeLogic, FavoriteListViewMode> {
  FavoritesViewModeLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesViewModeLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesViewModeLogicHash();

  @$internal
  @override
  FavoritesViewModeLogic create() => FavoritesViewModeLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteListViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteListViewMode>(value),
    );
  }
}

String _$favoritesViewModeLogicHash() =>
    r'413a2a83d3dfe57aacf36a9d486510f6c99280e0';

abstract class _$FavoritesViewModeLogic
    extends $Notifier<FavoriteListViewMode> {
  FavoriteListViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoriteListViewMode, FavoriteListViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoriteListViewMode, FavoriteListViewMode>,
              FavoriteListViewMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
