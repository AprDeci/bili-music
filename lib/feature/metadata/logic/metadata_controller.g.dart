// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetadataController)
final metadataControllerProvider = MetadataControllerProvider._();

final class MetadataControllerProvider
    extends $NotifierProvider<MetadataController, MetadataState> {
  MetadataControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metadataControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metadataControllerHash();

  @$internal
  @override
  MetadataController create() => MetadataController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetadataState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetadataState>(value),
    );
  }
}

String _$metadataControllerHash() =>
    r'70c4e1612cd1cc2a4821475e51d0b5c9c9f18076';

abstract class _$MetadataController extends $Notifier<MetadataState> {
  MetadataState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MetadataState, MetadataState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MetadataState, MetadataState>,
              MetadataState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
