// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyrics_cache_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerLyricsCacheRepository)
final playerLyricsCacheRepositoryProvider =
    PlayerLyricsCacheRepositoryProvider._();

final class PlayerLyricsCacheRepositoryProvider
    extends
        $FunctionalProvider<
          PlayerLyricsCacheRepository,
          PlayerLyricsCacheRepository,
          PlayerLyricsCacheRepository
        >
    with $Provider<PlayerLyricsCacheRepository> {
  PlayerLyricsCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLyricsCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerLyricsCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayerLyricsCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerLyricsCacheRepository create(Ref ref) {
    return playerLyricsCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerLyricsCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerLyricsCacheRepository>(value),
    );
  }
}

String _$playerLyricsCacheRepositoryHash() =>
    r'3265fe0a8c7c54cdc707e4e6d35ce1ad7aea70c8';
