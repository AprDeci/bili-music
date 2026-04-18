// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_audio_quality_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerAudioQualityPreferenceLogic)
final playerAudioQualityPreferenceLogicProvider =
    PlayerAudioQualityPreferenceLogicProvider._();

final class PlayerAudioQualityPreferenceLogicProvider
    extends
        $NotifierProvider<
          PlayerAudioQualityPreferenceLogic,
          PlayerAudioQualityPreference
        > {
  PlayerAudioQualityPreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerAudioQualityPreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$playerAudioQualityPreferenceLogicHash();

  @$internal
  @override
  PlayerAudioQualityPreferenceLogic create() =>
      PlayerAudioQualityPreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerAudioQualityPreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerAudioQualityPreference>(value),
    );
  }
}

String _$playerAudioQualityPreferenceLogicHash() =>
    r'ecc263c19d6774c487559c2b76819954ad42d0fb';

abstract class _$PlayerAudioQualityPreferenceLogic
    extends $Notifier<PlayerAudioQualityPreference> {
  PlayerAudioQualityPreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<PlayerAudioQualityPreference, PlayerAudioQualityPreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PlayerAudioQualityPreference,
                PlayerAudioQualityPreference
              >,
              PlayerAudioQualityPreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
