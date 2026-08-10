// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_event_hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerEventHub)
final playerEventHubProvider = PlayerEventHubProvider._();

final class PlayerEventHubProvider
    extends $FunctionalProvider<PlayerEventHub, PlayerEventHub, PlayerEventHub>
    with $Provider<PlayerEventHub> {
  PlayerEventHubProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerEventHubProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerEventHubHash();

  @$internal
  @override
  $ProviderElement<PlayerEventHub> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlayerEventHub create(Ref ref) {
    return playerEventHub(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerEventHub value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerEventHub>(value),
    );
  }
}

String _$playerEventHubHash() => r'1917e584d4ff76c0263d7ab424244ad60416746a';
