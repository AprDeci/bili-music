// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_queue_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerQueueLocalRepository)
final playerQueueLocalRepositoryProvider =
    PlayerQueueLocalRepositoryProvider._();

final class PlayerQueueLocalRepositoryProvider
    extends
        $FunctionalProvider<
          PlayerQueueLocalRepository,
          PlayerQueueLocalRepository,
          PlayerQueueLocalRepository
        >
    with $Provider<PlayerQueueLocalRepository> {
  PlayerQueueLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerQueueLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerQueueLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayerQueueLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerQueueLocalRepository create(Ref ref) {
    return playerQueueLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerQueueLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerQueueLocalRepository>(value),
    );
  }
}

String _$playerQueueLocalRepositoryHash() =>
    r'56d33895647e6d8767ab7ea50f1b0d2e2188643d';
