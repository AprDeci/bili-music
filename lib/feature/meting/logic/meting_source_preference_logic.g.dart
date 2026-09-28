// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meting_source_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetingSourcePreferenceLogic)
final metingSourcePreferenceLogicProvider =
    MetingSourcePreferenceLogicProvider._();

final class MetingSourcePreferenceLogicProvider
    extends
        $NotifierProvider<MetingSourcePreferenceLogic, MetingSourcePreference> {
  MetingSourcePreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metingSourcePreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metingSourcePreferenceLogicHash();

  @$internal
  @override
  MetingSourcePreferenceLogic create() => MetingSourcePreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetingSourcePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetingSourcePreference>(value),
    );
  }
}

String _$metingSourcePreferenceLogicHash() =>
    r'53c99250b9cc4a7363b93ead3f270d7d9fb121ac';

abstract class _$MetingSourcePreferenceLogic
    extends $Notifier<MetingSourcePreference> {
  MetingSourcePreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MetingSourcePreference, MetingSourcePreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MetingSourcePreference, MetingSourcePreference>,
              MetingSourcePreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
