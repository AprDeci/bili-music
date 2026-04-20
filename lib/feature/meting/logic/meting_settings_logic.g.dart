// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meting_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetingSettingsLogic)
final metingSettingsLogicProvider = MetingSettingsLogicProvider._();

final class MetingSettingsLogicProvider
    extends $NotifierProvider<MetingSettingsLogic, String> {
  MetingSettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metingSettingsLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metingSettingsLogicHash();

  @$internal
  @override
  MetingSettingsLogic create() => MetingSettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$metingSettingsLogicHash() =>
    r'0953a9cfca25e1a6f1ae36e136637cd9518fa397';

abstract class _$MetingSettingsLogic extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
