// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_ranking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliMusicRankingRepository)
final biliMusicRankingRepositoryProvider =
    BiliMusicRankingRepositoryProvider._();

final class BiliMusicRankingRepositoryProvider
    extends
        $FunctionalProvider<
          BiliMusicRankingRepository,
          BiliMusicRankingRepository,
          BiliMusicRankingRepository
        >
    with $Provider<BiliMusicRankingRepository> {
  BiliMusicRankingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliMusicRankingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliMusicRankingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliMusicRankingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliMusicRankingRepository create(Ref ref) {
    return biliMusicRankingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliMusicRankingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliMusicRankingRepository>(value),
    );
  }
}

String _$biliMusicRankingRepositoryHash() =>
    r'7c094e50ff20b66211300c6deee25f8df39a946c';

@ProviderFor(musicRanking)
final musicRankingProvider = MusicRankingProvider._();

final class MusicRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MusicRankingItem>>,
          List<MusicRankingItem>,
          FutureOr<List<MusicRankingItem>>
        >
    with
        $FutureModifier<List<MusicRankingItem>>,
        $FutureProvider<List<MusicRankingItem>> {
  MusicRankingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicRankingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicRankingHash();

  @$internal
  @override
  $FutureProviderElement<List<MusicRankingItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MusicRankingItem>> create(Ref ref) {
    return musicRanking(ref);
  }
}

String _$musicRankingHash() => r'135abe0bd82e76570555348cd93e8164145f62ab';
