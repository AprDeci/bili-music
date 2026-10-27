// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_display_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerDisplay)
final playerDisplayProvider = PlayerDisplayProvider._();

final class PlayerDisplayProvider
    extends
        $FunctionalProvider<
          PlayerDisplayInfo,
          PlayerDisplayInfo,
          PlayerDisplayInfo
        >
    with $Provider<PlayerDisplayInfo> {
  PlayerDisplayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerDisplayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerDisplayHash();

  @$internal
  @override
  $ProviderElement<PlayerDisplayInfo> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerDisplayInfo create(Ref ref) {
    return playerDisplay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerDisplayInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerDisplayInfo>(value),
    );
  }
}

String _$playerDisplayHash() => r'8fe04e3f66d73571e9645c0d828ac1e66252478f';
