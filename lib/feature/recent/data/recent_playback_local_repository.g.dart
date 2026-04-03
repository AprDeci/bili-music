// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_playback_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recentPlaybackLocalRepository)
final recentPlaybackLocalRepositoryProvider =
    RecentPlaybackLocalRepositoryProvider._();

final class RecentPlaybackLocalRepositoryProvider
    extends
        $FunctionalProvider<
          RecentPlaybackLocalRepository,
          RecentPlaybackLocalRepository,
          RecentPlaybackLocalRepository
        >
    with $Provider<RecentPlaybackLocalRepository> {
  RecentPlaybackLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPlaybackLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPlaybackLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecentPlaybackLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentPlaybackLocalRepository create(Ref ref) {
    return recentPlaybackLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentPlaybackLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentPlaybackLocalRepository>(
        value,
      ),
    );
  }
}

String _$recentPlaybackLocalRepositoryHash() =>
    r'876f1acd64dbf64f4e682edb43967bfd7c516285';
