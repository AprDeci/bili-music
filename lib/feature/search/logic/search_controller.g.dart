// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliSearchRepository)
final biliSearchRepositoryProvider = BiliSearchRepositoryProvider._();

final class BiliSearchRepositoryProvider
    extends
        $FunctionalProvider<
          BiliSearchRepository,
          BiliSearchRepository,
          BiliSearchRepository
        >
    with $Provider<BiliSearchRepository> {
  BiliSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliSearchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliSearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliSearchRepository create(Ref ref) {
    return biliSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliSearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliSearchRepository>(value),
    );
  }
}

String _$biliSearchRepositoryHash() =>
    r'a09b29d03e173da28c5f96721ee1a7392d2bfbb8';

@ProviderFor(SearchPageController)
final searchPageControllerProvider = SearchPageControllerProvider._();

final class SearchPageControllerProvider
    extends $NotifierProvider<SearchPageController, SearchState> {
  SearchPageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchPageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchPageControllerHash();

  @$internal
  @override
  SearchPageController create() => SearchPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchPageControllerHash() =>
    r'b521e949cf9f60df477be6612c3d20120f68ddea';

abstract class _$SearchPageController extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
