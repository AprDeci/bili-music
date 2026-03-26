// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_wbi_signer.dart';

// ***************************************************************************
// RiverpodGenerator
// ***************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliWbiSigner)
final biliWbiSignerProvider = BiliWbiSignerProvider._();

final class BiliWbiSignerProvider
    extends $FunctionalProvider<BiliWbiSigner, BiliWbiSigner, BiliWbiSigner>
    with $Provider<BiliWbiSigner> {
  BiliWbiSignerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliWbiSignerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliWbiSignerHash();

  @$internal
  @override
  $ProviderElement<BiliWbiSigner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiliWbiSigner create(Ref ref) {
    return biliWbiSigner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliWbiSigner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliWbiSigner>(value),
    );
  }
}

String _$biliWbiSignerHash() =>
    r'6c168a72f246441ae8f1d1c0b5870ff861d6328a';
