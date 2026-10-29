// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_cover_color_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerArtworkColor)
final playerArtworkColorProvider = PlayerArtworkColorFamily._();

final class PlayerArtworkColorProvider
    extends $FunctionalProvider<AsyncValue<Color?>, Color?, FutureOr<Color?>>
    with $FutureModifier<Color?>, $FutureProvider<Color?> {
  PlayerArtworkColorProvider._({
    required PlayerArtworkColorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerArtworkColorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerArtworkColorHash();

  @override
  String toString() {
    return r'playerArtworkColorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Color?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Color?> create(Ref ref) {
    final argument = this.argument as String;
    return playerArtworkColor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerArtworkColorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerArtworkColorHash() =>
    r'ffca33ca88edb5f8a602fdabfdea5ce551766459';

final class PlayerArtworkColorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Color?>, String> {
  PlayerArtworkColorFamily._()
    : super(
        retry: null,
        name: r'playerArtworkColorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerArtworkColorProvider call(String coverUrl) =>
      PlayerArtworkColorProvider._(argument: coverUrl, from: this);

  @override
  String toString() => r'playerArtworkColorProvider';
}

@ProviderFor(PlayerCoverColorController)
final playerCoverColorControllerProvider =
    PlayerCoverColorControllerProvider._();

final class PlayerCoverColorControllerProvider
    extends $NotifierProvider<PlayerCoverColorController, Color?> {
  PlayerCoverColorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerCoverColorControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerCoverColorControllerHash();

  @$internal
  @override
  PlayerCoverColorController create() => PlayerCoverColorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color?>(value),
    );
  }
}

String _$playerCoverColorControllerHash() =>
    r'104611ab0b8696c32a50116069771331ed2a8c6f';

abstract class _$PlayerCoverColorController extends $Notifier<Color?> {
  Color? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Color?, Color?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Color?, Color?>,
              Color?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
