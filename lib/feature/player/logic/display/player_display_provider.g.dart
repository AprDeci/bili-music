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

@ProviderFor(playerQueueDisplay)
final playerQueueDisplayProvider = PlayerQueueDisplayFamily._();

final class PlayerQueueDisplayProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerDisplayInfo>,
          PlayerDisplayInfo,
          FutureOr<PlayerDisplayInfo>
        >
    with
        $FutureModifier<PlayerDisplayInfo>,
        $FutureProvider<PlayerDisplayInfo> {
  PlayerQueueDisplayProvider._({
    required PlayerQueueDisplayFamily super.from,
    required PlayableItem super.argument,
  }) : super(
         retry: null,
         name: r'playerQueueDisplayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerQueueDisplayHash();

  @override
  String toString() {
    return r'playerQueueDisplayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlayerDisplayInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlayerDisplayInfo> create(Ref ref) {
    final argument = this.argument as PlayableItem;
    return playerQueueDisplay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerQueueDisplayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerQueueDisplayHash() =>
    r'9d226bd737e26eceea83b91019fd2f033ff6394b';

final class PlayerQueueDisplayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlayerDisplayInfo>, PlayableItem> {
  PlayerQueueDisplayFamily._()
    : super(
        retry: null,
        name: r'playerQueueDisplayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerQueueDisplayProvider call(PlayableItem item) =>
      PlayerQueueDisplayProvider._(argument: item, from: this);

  @override
  String toString() => r'playerQueueDisplayProvider';
}
