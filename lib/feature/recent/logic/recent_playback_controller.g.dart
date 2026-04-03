// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_playback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentPlaybackController)
final recentPlaybackControllerProvider = RecentPlaybackControllerProvider._();

final class RecentPlaybackControllerProvider
    extends
        $NotifierProvider<RecentPlaybackController, List<RecentPlaybackEntry>> {
  RecentPlaybackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPlaybackControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPlaybackControllerHash();

  @$internal
  @override
  RecentPlaybackController create() => RecentPlaybackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RecentPlaybackEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RecentPlaybackEntry>>(value),
    );
  }
}

String _$recentPlaybackControllerHash() =>
    r'48ebd890974965e170c32340b0f58df75cff3e32';

abstract class _$RecentPlaybackController
    extends $Notifier<List<RecentPlaybackEntry>> {
  List<RecentPlaybackEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<RecentPlaybackEntry>, List<RecentPlaybackEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RecentPlaybackEntry>, List<RecentPlaybackEntry>>,
              List<RecentPlaybackEntry>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
