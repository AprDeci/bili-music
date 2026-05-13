// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bm_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BmClient)
final bmClientProvider = BmClientProvider._();

final class BmClientProvider extends $NotifierProvider<BmClient, Dio> {
  BmClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bmClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bmClientHash();

  @$internal
  @override
  BmClient create() => BmClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$bmClientHash() => r'3439a39b96f911b645e531eb9ab8066f05948688';

abstract class _$BmClient extends $Notifier<Dio> {
  Dio build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Dio, Dio>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Dio, Dio>,
              Dio,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
