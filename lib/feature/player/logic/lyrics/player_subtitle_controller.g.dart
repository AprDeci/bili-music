// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_subtitle_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliSubtitleRepository)
final biliSubtitleRepositoryProvider = BiliSubtitleRepositoryProvider._();

final class BiliSubtitleRepositoryProvider
    extends
        $FunctionalProvider<
          BiliSubtitleRepository,
          BiliSubtitleRepository,
          BiliSubtitleRepository
        >
    with $Provider<BiliSubtitleRepository> {
  BiliSubtitleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliSubtitleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliSubtitleRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliSubtitleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliSubtitleRepository create(Ref ref) {
    return biliSubtitleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliSubtitleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliSubtitleRepository>(value),
    );
  }
}

String _$biliSubtitleRepositoryHash() =>
    r'4ae452789c56f98ffe06a8ebcd55fe9a07df8c8b';

@ProviderFor(PlayerSubtitleController)
final playerSubtitleControllerProvider = PlayerSubtitleControllerProvider._();

final class PlayerSubtitleControllerProvider
    extends $NotifierProvider<PlayerSubtitleController, PlayerSubtitleState> {
  PlayerSubtitleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerSubtitleControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerSubtitleControllerHash();

  @$internal
  @override
  PlayerSubtitleController create() => PlayerSubtitleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerSubtitleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerSubtitleState>(value),
    );
  }
}

String _$playerSubtitleControllerHash() =>
    r'113860d640b2a376cc43cee557e3710d1106fe3c';

abstract class _$PlayerSubtitleController
    extends $Notifier<PlayerSubtitleState> {
  PlayerSubtitleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayerSubtitleState, PlayerSubtitleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerSubtitleState, PlayerSubtitleState>,
              PlayerSubtitleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
