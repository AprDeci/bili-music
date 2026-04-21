// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyrics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerLyricsController)
final playerLyricsControllerProvider = PlayerLyricsControllerProvider._();

final class PlayerLyricsControllerProvider
    extends $NotifierProvider<PlayerLyricsController, PlayerLyricsState> {
  PlayerLyricsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLyricsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerLyricsControllerHash();

  @$internal
  @override
  PlayerLyricsController create() => PlayerLyricsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerLyricsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerLyricsState>(value),
    );
  }
}

String _$playerLyricsControllerHash() =>
    r'a182f768efe01963ce6381ccac69df9c092ed427';

abstract class _$PlayerLyricsController extends $Notifier<PlayerLyricsState> {
  PlayerLyricsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayerLyricsState, PlayerLyricsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerLyricsState, PlayerLyricsState>,
              PlayerLyricsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
