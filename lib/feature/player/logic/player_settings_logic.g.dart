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
    r'30f9e59593078ca57d6f41fd3f18064c8d3b1bb3';

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
