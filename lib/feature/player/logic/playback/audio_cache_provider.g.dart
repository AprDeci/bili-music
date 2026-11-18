// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_cache_provider.dart';

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
        isAutoDispose: false,
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
    r'c21fabdb1aa18cc7deeeb903fdf215232d955223';

@ProviderFor(AudioCacheLimitLogic)
final audioCacheLimitLogicProvider = AudioCacheLimitLogicProvider._();

final class AudioCacheLimitLogicProvider
    extends $NotifierProvider<AudioCacheLimitLogic, AudioCacheLimit> {
  AudioCacheLimitLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioCacheLimitLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioCacheLimitLogicHash();

  @$internal
  @override
  AudioCacheLimitLogic create() => AudioCacheLimitLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioCacheLimit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioCacheLimit>(value),
    );
  }
}

String _$audioCacheLimitLogicHash() =>
    r'a5f4ae711899bd8a71d9754de8e0760bba082870';

abstract class _$AudioCacheLimitLogic extends $Notifier<AudioCacheLimit> {
  AudioCacheLimit build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AudioCacheLimit, AudioCacheLimit>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioCacheLimit, AudioCacheLimit>,
              AudioCacheLimit,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
