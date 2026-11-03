// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_ui_setting_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CarUiSettingLogic)
final carUiSettingLogicProvider = CarUiSettingLogicProvider._();

final class CarUiSettingLogicProvider
    extends $NotifierProvider<CarUiSettingLogic, bool> {
  CarUiSettingLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carUiSettingLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carUiSettingLogicHash();

  @$internal
  @override
  CarUiSettingLogic create() => CarUiSettingLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$carUiSettingLogicHash() => r'9bb4d71e8bfc33a062cec756d924eae874d75339';

abstract class _$CarUiSettingLogic extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
