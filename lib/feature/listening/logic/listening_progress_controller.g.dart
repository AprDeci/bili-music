// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_progress_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listeningProgressLocalRepository)
final listeningProgressLocalRepositoryProvider =
    ListeningProgressLocalRepositoryProvider._();

final class ListeningProgressLocalRepositoryProvider
    extends
        $FunctionalProvider<
          ListeningProgressLocalRepository,
          ListeningProgressLocalRepository,
          ListeningProgressLocalRepository
        >
    with $Provider<ListeningProgressLocalRepository> {
  ListeningProgressLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listeningProgressLocalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listeningProgressLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListeningProgressLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListeningProgressLocalRepository create(Ref ref) {
    return listeningProgressLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListeningProgressLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListeningProgressLocalRepository>(
        value,
      ),
    );
  }
}

String _$listeningProgressLocalRepositoryHash() =>
    r'4729867d4f24a36c5f29e8b901ea3a3aed71ebf5';

@ProviderFor(biliHistoryRemoteRepository)
final biliHistoryRemoteRepositoryProvider =
    BiliHistoryRemoteRepositoryProvider._();

final class BiliHistoryRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          BiliHistoryRemoteRepository,
          BiliHistoryRemoteRepository,
          BiliHistoryRemoteRepository
        >
    with $Provider<BiliHistoryRemoteRepository> {
  BiliHistoryRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliHistoryRemoteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliHistoryRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliHistoryRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliHistoryRemoteRepository create(Ref ref) {
    return biliHistoryRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliHistoryRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliHistoryRemoteRepository>(value),
    );
  }
}

String _$biliHistoryRemoteRepositoryHash() =>
    r'57008f8a153880d64cd8daa46c127ffa310dc7b7';

@ProviderFor(ListeningProgressController)
final listeningProgressControllerProvider =
    ListeningProgressControllerProvider._();

final class ListeningProgressControllerProvider
    extends $NotifierProvider<ListeningProgressController, ListeningState> {
  ListeningProgressControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listeningProgressControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listeningProgressControllerHash();

  @$internal
  @override
  ListeningProgressController create() => ListeningProgressController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListeningState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListeningState>(value),
    );
  }
}

String _$listeningProgressControllerHash() =>
    r'92fbaccbb66a0f9bb0d09cdddee60d7a814bc106';

abstract class _$ListeningProgressController extends $Notifier<ListeningState> {
  ListeningState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ListeningState, ListeningState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListeningState, ListeningState>,
              ListeningState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
