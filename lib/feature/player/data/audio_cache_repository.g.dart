// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_cache_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerAudioCacheRepository)
final playerAudioCacheRepositoryProvider =
    PlayerAudioCacheRepositoryProvider._();

final class PlayerAudioCacheRepositoryProvider
    extends
        $FunctionalProvider<
          PlayerAudioCacheRepository,
          PlayerAudioCacheRepository,
          PlayerAudioCacheRepository
        >
    with $Provider<PlayerAudioCacheRepository> {
  PlayerAudioCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerAudioCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerAudioCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayerAudioCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerAudioCacheRepository create(Ref ref) {
    return playerAudioCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerAudioCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerAudioCacheRepository>(value),
    );
  }
}

String _$playerAudioCacheRepositoryHash() =>
    r'b2a6600185ab8335b9583e4eba574b8d362a36e4';
