// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliApiClient)
final biliApiClientProvider = BiliApiClientProvider._();

final class BiliApiClientProvider
    extends $FunctionalProvider<BiliApiClient, BiliApiClient, BiliApiClient>
    with $Provider<BiliApiClient> {
  BiliApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliApiClientHash();

  @$internal
  @override
  $ProviderElement<BiliApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiliApiClient create(Ref ref) {
    return biliApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliApiClient>(value),
    );
  }
}

String _$biliApiClientHash() => r'47ab646db7ea1dc30e71ebd0e4989feea898a72f';
