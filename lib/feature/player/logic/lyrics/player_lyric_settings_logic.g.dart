// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyric_settings_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerLyricSettingsLogic)
final playerLyricSettingsLogicProvider = PlayerLyricSettingsLogicProvider._();

final class PlayerLyricSettingsLogicProvider
    extends $NotifierProvider<PlayerLyricSettingsLogic, PlayerLyricSettings> {
  PlayerLyricSettingsLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLyricSettingsLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerLyricSettingsLogicHash();

  @$internal
  @override
  PlayerLyricSettingsLogic create() => PlayerLyricSettingsLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerLyricSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerLyricSettings>(value),
    );
  }
}

String _$playerLyricSettingsLogicHash() =>
    r'199ce98defe9468e449ec32ca8d04fc4512297f2';

abstract class _$PlayerLyricSettingsLogic
    extends $Notifier<PlayerLyricSettings> {
  PlayerLyricSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayerLyricSettings, PlayerLyricSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerLyricSettings, PlayerLyricSettings>,
              PlayerLyricSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
