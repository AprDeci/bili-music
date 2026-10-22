// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_ui_style_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerUiStyleLogic)
final playerUiStyleLogicProvider = PlayerUiStyleLogicProvider._();

final class PlayerUiStyleLogicProvider
    extends $NotifierProvider<PlayerUiStyleLogic, PlayerUiStyle> {
  PlayerUiStyleLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerUiStyleLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerUiStyleLogicHash();

  @$internal
  @override
  PlayerUiStyleLogic create() => PlayerUiStyleLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerUiStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerUiStyle>(value),
    );
  }
}

String _$playerUiStyleLogicHash() =>
    r'c2d465221fd9a672704b8dd68ccfc6192812c333';

abstract class _$PlayerUiStyleLogic extends $Notifier<PlayerUiStyle> {
  PlayerUiStyle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayerUiStyle, PlayerUiStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerUiStyle, PlayerUiStyle>,
              PlayerUiStyle,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
