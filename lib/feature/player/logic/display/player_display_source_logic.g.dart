// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_display_source_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerDisplaySourceLogic)
final playerDisplaySourceLogicProvider = PlayerDisplaySourceLogicProvider._();

final class PlayerDisplaySourceLogicProvider
    extends $NotifierProvider<PlayerDisplaySourceLogic, PlayerDisplaySource?> {
  PlayerDisplaySourceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerDisplaySourceLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerDisplaySourceLogicHash();

  @$internal
  @override
  PlayerDisplaySourceLogic create() => PlayerDisplaySourceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerDisplaySource? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerDisplaySource?>(value),
    );
  }
}

String _$playerDisplaySourceLogicHash() =>
    r'a930d3a91dd6384c5d9fbe2545a539c5a1d33c38';

abstract class _$PlayerDisplaySourceLogic
    extends $Notifier<PlayerDisplaySource?> {
  PlayerDisplaySource? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayerDisplaySource?, PlayerDisplaySource?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerDisplaySource?, PlayerDisplaySource?>,
              PlayerDisplaySource?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
