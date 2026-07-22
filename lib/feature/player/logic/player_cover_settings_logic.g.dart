// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_cover_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerCoverSettingsLogic)
final playerCoverSettingsLogicProvider = PlayerCoverSettingsLogicProvider._();

final class PlayerCoverSettingsLogicProvider
    extends $NotifierProvider<PlayerCoverSettingsLogic, bool> {
  PlayerCoverSettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerCoverSettingsLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerCoverSettingsLogicHash();

  @$internal
  @override
  PlayerCoverSettingsLogic create() => PlayerCoverSettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$playerCoverSettingsLogicHash() =>
    r'4aa47c56a22e2b7e3d249607d81fb9da228b23ae';

abstract class _$PlayerCoverSettingsLogic extends $Notifier<bool> {
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
