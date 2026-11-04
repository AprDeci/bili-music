// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_chapter_marker_style_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerChapterMarkerStyleLogic)
final playerChapterMarkerStyleLogicProvider =
    PlayerChapterMarkerStyleLogicProvider._();

final class PlayerChapterMarkerStyleLogicProvider
    extends
        $NotifierProvider<
          PlayerChapterMarkerStyleLogic,
          PlayerChapterMarkerStyle
        > {
  PlayerChapterMarkerStyleLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerChapterMarkerStyleLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerChapterMarkerStyleLogicHash();

  @$internal
  @override
  PlayerChapterMarkerStyleLogic create() => PlayerChapterMarkerStyleLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerChapterMarkerStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerChapterMarkerStyle>(value),
    );
  }
}

String _$playerChapterMarkerStyleLogicHash() =>
    r'4faf3b59506a203de8d99ed7e3de6fbfb2c99c91';

abstract class _$PlayerChapterMarkerStyleLogic
    extends $Notifier<PlayerChapterMarkerStyle> {
  PlayerChapterMarkerStyle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PlayerChapterMarkerStyle, PlayerChapterMarkerStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerChapterMarkerStyle, PlayerChapterMarkerStyle>,
              PlayerChapterMarkerStyle,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
