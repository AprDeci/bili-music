// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotkey_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HotkeySettingsLogic)
final hotkeySettingsLogicProvider = HotkeySettingsLogicProvider._();

final class HotkeySettingsLogicProvider
    extends $NotifierProvider<HotkeySettingsLogic, List<HotkeyBinding>> {
  HotkeySettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotkeySettingsLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotkeySettingsLogicHash();

  @$internal
  @override
  HotkeySettingsLogic create() => HotkeySettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HotkeyBinding> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HotkeyBinding>>(value),
    );
  }
}

String _$hotkeySettingsLogicHash() =>
    r'8a312d386fef509e066a707b60a6c345be3c9d74';

abstract class _$HotkeySettingsLogic extends $Notifier<List<HotkeyBinding>> {
  List<HotkeyBinding> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<HotkeyBinding>, List<HotkeyBinding>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<HotkeyBinding>, List<HotkeyBinding>>,
              List<HotkeyBinding>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
