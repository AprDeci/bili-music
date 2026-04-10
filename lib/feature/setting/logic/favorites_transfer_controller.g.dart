// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_transfer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesTransferController)
final favoritesTransferControllerProvider =
    FavoritesTransferControllerProvider._();

final class FavoritesTransferControllerProvider
    extends
        $FunctionalProvider<
          FavoritesTransferController,
          FavoritesTransferController,
          FavoritesTransferController
        >
    with $Provider<FavoritesTransferController> {
  FavoritesTransferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesTransferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesTransferControllerHash();

  @$internal
  @override
  $ProviderElement<FavoritesTransferController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesTransferController create(Ref ref) {
    return favoritesTransferController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesTransferController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesTransferController>(value),
    );
  }
}

String _$favoritesTransferControllerHash() =>
    r'b6eea732f52c8b70ffe54bf0095af7f51932c943';
