// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_blacklist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerBlacklistController)
final playerBlacklistControllerProvider = PlayerBlacklistControllerProvider._();

final class PlayerBlacklistControllerProvider
    extends
        $NotifierProvider<
          PlayerBlacklistController,
          List<PlayerBlacklistEntry>
        > {
  PlayerBlacklistControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerBlacklistControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerBlacklistControllerHash();

  @$internal
  @override
  PlayerBlacklistController create() => PlayerBlacklistController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlayerBlacklistEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlayerBlacklistEntry>>(value),
    );
  }
}

String _$playerBlacklistControllerHash() =>
    r'04e3850a34cab5367542179963c6adde973df70c';

abstract class _$PlayerBlacklistController
    extends $Notifier<List<PlayerBlacklistEntry>> {
  List<PlayerBlacklistEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<List<PlayerBlacklistEntry>, List<PlayerBlacklistEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<PlayerBlacklistEntry>,
                List<PlayerBlacklistEntry>
              >,
              List<PlayerBlacklistEntry>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
