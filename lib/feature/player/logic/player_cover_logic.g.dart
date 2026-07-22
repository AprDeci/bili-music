// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_cover_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerCoverLogic)
final playerCoverLogicProvider = PlayerCoverLogicProvider._();

final class PlayerCoverLogicProvider
    extends $NotifierProvider<PlayerCoverLogic, bool?> {
  PlayerCoverLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerCoverLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerCoverLogicHash();

  @$internal
  @override
  PlayerCoverLogic create() => PlayerCoverLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$playerCoverLogicHash() => r'0c3b67ceddae22f4c97d363f9b621da95c12acbe';

abstract class _$PlayerCoverLogic extends $Notifier<bool?> {
  bool? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool?, bool?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool?, bool?>,
              bool?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
