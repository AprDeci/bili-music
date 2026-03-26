// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_session_store.dart';

// ***************************************************************************
// RiverpodGenerator
// ***************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliSessionStore)
final biliSessionStoreProvider = BiliSessionStoreProvider._();

final class BiliSessionStoreProvider
    extends
        $FunctionalProvider<
          BiliSessionStore,
          BiliSessionStore,
          BiliSessionStore
        >
    with $Provider<BiliSessionStore> {
  BiliSessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliSessionStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliSessionStoreHash();

  @$internal
  @override
  $ProviderElement<BiliSessionStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliSessionStore create(Ref ref) {
    return biliSessionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliSessionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliSessionStore>(value),
    );
  }
}

String _$biliSessionStoreHash() =>
    r'01f0c5f5e7e8b4e7e1e80f8acd7c37953b1cd12d';
