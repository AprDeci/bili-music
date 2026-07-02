// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyric_font_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerLyricFontPreferenceLogic)
final playerLyricFontPreferenceLogicProvider =
    PlayerLyricFontPreferenceLogicProvider._();

final class PlayerLyricFontPreferenceLogicProvider
    extends
        $NotifierProvider<
          PlayerLyricFontPreferenceLogic,
          PlayerLyricFontPreference
        > {
  PlayerLyricFontPreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLyricFontPreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerLyricFontPreferenceLogicHash();

  @$internal
  @override
  PlayerLyricFontPreferenceLogic create() => PlayerLyricFontPreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerLyricFontPreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerLyricFontPreference>(value),
    );
  }
}

String _$playerLyricFontPreferenceLogicHash() =>
    r'32f3bae3c09e76eb53c6011c313340d4357f8082';

abstract class _$PlayerLyricFontPreferenceLogic
    extends $Notifier<PlayerLyricFontPreference> {
  PlayerLyricFontPreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PlayerLyricFontPreference, PlayerLyricFontPreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerLyricFontPreference, PlayerLyricFontPreference>,
              PlayerLyricFontPreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
