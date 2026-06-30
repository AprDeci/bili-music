// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_multi_part_queue_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerMultiPartQueuePreferenceLogic)
final playerMultiPartQueuePreferenceLogicProvider =
    PlayerMultiPartQueuePreferenceLogicProvider._();

final class PlayerMultiPartQueuePreferenceLogicProvider
    extends
        $NotifierProvider<
          PlayerMultiPartQueuePreferenceLogic,
          MultiPartQueuePreference
        > {
  PlayerMultiPartQueuePreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerMultiPartQueuePreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$playerMultiPartQueuePreferenceLogicHash();

  @$internal
  @override
  PlayerMultiPartQueuePreferenceLogic create() =>
      PlayerMultiPartQueuePreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MultiPartQueuePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MultiPartQueuePreference>(value),
    );
  }
}

String _$playerMultiPartQueuePreferenceLogicHash() =>
    r'6ebdcc6de497ba073d6b7cfcf3ce83e5ed6061f2';

abstract class _$PlayerMultiPartQueuePreferenceLogic
    extends $Notifier<MultiPartQueuePreference> {
  MultiPartQueuePreference build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MultiPartQueuePreference, MultiPartQueuePreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MultiPartQueuePreference, MultiPartQueuePreference>,
              MultiPartQueuePreference,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PlayerMultiPartTipShownLogic)
final playerMultiPartTipShownLogicProvider =
    PlayerMultiPartTipShownLogicProvider._();

final class PlayerMultiPartTipShownLogicProvider
    extends $NotifierProvider<PlayerMultiPartTipShownLogic, bool> {
  PlayerMultiPartTipShownLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerMultiPartTipShownLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerMultiPartTipShownLogicHash();

  @$internal
  @override
  PlayerMultiPartTipShownLogic create() => PlayerMultiPartTipShownLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$playerMultiPartTipShownLogicHash() =>
    r'0c72c91634def2499dcd59dd3a6794202c3a94ce';

abstract class _$PlayerMultiPartTipShownLogic extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
