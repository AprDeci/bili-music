// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_cover_color_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'3fb5bcdf52782a7433076ffad0ab6dfccc903fb6';

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
