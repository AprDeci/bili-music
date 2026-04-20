// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meting_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetingClient)
final metingClientProvider = MetingClientProvider._();

final class MetingClientProvider extends $NotifierProvider<MetingClient, Dio> {
  MetingClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metingClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metingClientHash();

  @$internal
  @override
  MetingClient create() => MetingClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$metingClientHash() => r'a79fd3e553fe536a8f8ad0932439c58bb418877e';

abstract class _$MetingClient extends $Notifier<Dio> {
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
