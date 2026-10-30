// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_view_mode_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesViewModeLogic)
final favoritesViewModeLogicProvider = FavoritesViewModeLogicFamily._();

final class FavoritesViewModeLogicProvider
    extends $NotifierProvider<FavoritesViewModeLogic, FavoriteListViewMode> {
  FavoritesViewModeLogicProvider._({
    required FavoritesViewModeLogicFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'favoritesViewModeLogicProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoritesViewModeLogicHash();

  @override
  String toString() {
    return r'favoritesViewModeLogicProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is FavoritesViewModeLogicProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoritesViewModeLogicHash() =>
    r'8bd9de819d750e7de5e075f3b8961283686af83f';

final class FavoritesViewModeLogicFamily extends $Family
    with
        $ClassFamilyOverride<
          FavoritesViewModeLogic,
          FavoriteListViewMode,
          FavoriteListViewMode,
          FavoriteListViewMode,
          String
        > {
  FavoritesViewModeLogicFamily._()
    : super(
        retry: null,
        name: r'favoritesViewModeLogicProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FavoritesViewModeLogicProvider call(String collectionId) =>
      FavoritesViewModeLogicProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'favoritesViewModeLogicProvider';
}

abstract class _$FavoritesViewModeLogic
    extends $Notifier<FavoriteListViewMode> {
  late final _$args = ref.$arg as String;
  String get collectionId => _$args;

  FavoriteListViewMode build(String collectionId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
