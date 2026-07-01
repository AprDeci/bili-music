// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoriteUpController)
final favoriteUpControllerProvider = FavoriteUpControllerProvider._();

final class FavoriteUpControllerProvider
    extends $NotifierProvider<FavoriteUpController, List<FavoriteUp>> {
  FavoriteUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteUpControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteUpControllerHash();

  @$internal
  @override
  FavoriteUpController create() => FavoriteUpController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FavoriteUp> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FavoriteUp>>(value),
    );
  }
}

String _$favoriteUpControllerHash() =>
    r'67caf032eef28f786775ca206970da54c2c6fb29';

abstract class _$FavoriteUpController extends $Notifier<List<FavoriteUp>> {
  List<FavoriteUp> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<FavoriteUp>, List<FavoriteUp>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<FavoriteUp>, List<FavoriteUp>>,
              List<FavoriteUp>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
