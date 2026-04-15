// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_setting_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppearanceSettingLogic)
final appearanceSettingLogicProvider = AppearanceSettingLogicProvider._();

final class AppearanceSettingLogicProvider
    extends $NotifierProvider<AppearanceSettingLogic, bool> {
  AppearanceSettingLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceSettingLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceSettingLogicHash();

  @$internal
  @override
  AppearanceSettingLogic create() => AppearanceSettingLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appearanceSettingLogicHash() =>
    r'684cdbe4b9b7aa376a6803b57ac2d68d4d0dabce';

abstract class _$AppearanceSettingLogic extends $Notifier<bool> {
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
