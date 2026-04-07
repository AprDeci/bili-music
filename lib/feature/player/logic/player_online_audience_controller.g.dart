// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_online_audience_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerOnlineAudienceController)
final playerOnlineAudienceControllerProvider =
    PlayerOnlineAudienceControllerProvider._();

final class PlayerOnlineAudienceControllerProvider
    extends
        $AsyncNotifierProvider<
          PlayerOnlineAudienceController,
          PlayerOnlineAudience?
        > {
  PlayerOnlineAudienceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerOnlineAudienceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerOnlineAudienceControllerHash();

  @$internal
  @override
  PlayerOnlineAudienceController create() => PlayerOnlineAudienceController();
}

String _$playerOnlineAudienceControllerHash() =>
    r'32061ed1325f80b1f063ea4ed9c05021533b39df';

abstract class _$PlayerOnlineAudienceController
    extends $AsyncNotifier<PlayerOnlineAudience?> {
  FutureOr<PlayerOnlineAudience?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PlayerOnlineAudience?>, PlayerOnlineAudience?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PlayerOnlineAudience?>,
                PlayerOnlineAudience?
              >,
              AsyncValue<PlayerOnlineAudience?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
