// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_display_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerDisplaySettingsLogic)
final playerDisplaySettingsLogicProvider =
    PlayerDisplaySettingsLogicProvider._();

final class PlayerDisplaySettingsLogicProvider
    extends $NotifierProvider<PlayerDisplaySettingsLogic, bool> {
  PlayerDisplaySettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerDisplaySettingsLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerDisplaySettingsLogicHash();

  @$internal
  @override
  PlayerDisplaySettingsLogic create() => PlayerDisplaySettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$playerDisplaySettingsLogicHash() =>
    r'2abb5bcb8c1ec8783faeacc38c2794901a8d30c0';

abstract class _$PlayerDisplaySettingsLogic extends $Notifier<bool> {
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
