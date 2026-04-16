// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webdav_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webDavLogic)
final webDavLogicProvider = WebDavLogicProvider._();

final class WebDavLogicProvider
    extends $FunctionalProvider<WebDavLogic, WebDavLogic, WebDavLogic>
    with $Provider<WebDavLogic> {
  WebDavLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDavLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDavLogicHash();

  @$internal
  @override
  $ProviderElement<WebDavLogic> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebDavLogic create(Ref ref) {
    return webDavLogic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDavLogic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDavLogic>(value),
    );
  }
}

String _$webDavLogicHash() => r'c9cd003071f9abf1ff4166cdf86e1d440dd1f1c6';
