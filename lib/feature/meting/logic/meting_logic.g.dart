// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meting_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metingLogic)
final metingLogicProvider = MetingLogicProvider._();

final class MetingLogicProvider
    extends $FunctionalProvider<MetingLogic, MetingLogic, MetingLogic>
    with $Provider<MetingLogic> {
  MetingLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metingLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metingLogicHash();

  @$internal
  @override
  $ProviderElement<MetingLogic> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MetingLogic create(Ref ref) {
    return metingLogic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetingLogic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetingLogic>(value),
    );
  }
}

String _$metingLogicHash() => r'5b193a7df79037a55096eb69d26a6ee606f3efb2';
