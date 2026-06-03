// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesImportController)
final favoritesImportControllerProvider = FavoritesImportControllerProvider._();

final class FavoritesImportControllerProvider
    extends $NotifierProvider<FavoritesImportController, FavoritesImportState> {
  FavoritesImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesImportControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesImportControllerHash();

  @$internal
  @override
  FavoritesImportController create() => FavoritesImportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesImportState>(value),
    );
  }
}

String _$favoritesImportControllerHash() =>
    r'22a213c21e46a97883adb15b34709a797c02f1b6';

abstract class _$FavoritesImportController
    extends $Notifier<FavoritesImportState> {
  FavoritesImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoritesImportState, FavoritesImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoritesImportState, FavoritesImportState>,
              FavoritesImportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
