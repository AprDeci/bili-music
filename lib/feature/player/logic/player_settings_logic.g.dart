// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerSettingsLogic)
final playerSettingsLogicProvider = PlayerSettingsLogicProvider._();

final class PlayerSettingsLogicProvider
    extends $NotifierProvider<PlayerSettingsLogic, bool> {
  PlayerSettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerSettingsLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerSettingsLogicHash();

  @$internal
  @override
  PlayerSettingsLogic create() => PlayerSettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$playerSettingsLogicHash() =>
    r'257a6e8c865d0104efa777e89bfd5478b5b66857';

abstract class _$PlayerSettingsLogic extends $Notifier<bool> {
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
