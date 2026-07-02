// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyric_font_size_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerLyricFontSizePreferenceLogic)
final playerLyricFontSizePreferenceLogicProvider =
    PlayerLyricFontSizePreferenceLogicProvider._();

final class PlayerLyricFontSizePreferenceLogicProvider
    extends
        $NotifierProvider<
          PlayerLyricFontSizePreferenceLogic,
          PlayerLyricFontSizePreference
        > {
  PlayerLyricFontSizePreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLyricFontSizePreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$playerLyricFontSizePreferenceLogicHash();

  @$internal
  @override
  PlayerLyricFontSizePreferenceLogic create() =>
      PlayerLyricFontSizePreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerLyricFontSizePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerLyricFontSizePreference>(
        value,
      ),
    );
  }
}

String _$playerLyricFontSizePreferenceLogicHash() =>
    r'd95fe228f9ff8b4012722cf618290d25022f95ad';

abstract class _$PlayerLyricFontSizePreferenceLogic
    extends $Notifier<PlayerLyricFontSizePreference> {
  PlayerLyricFontSizePreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              PlayerLyricFontSizePreference,
              PlayerLyricFontSizePreference
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PlayerLyricFontSizePreference,
                PlayerLyricFontSizePreference
              >,
              PlayerLyricFontSizePreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
