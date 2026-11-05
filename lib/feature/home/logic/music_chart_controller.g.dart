// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_chart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musicChartRepository)
final musicChartRepositoryProvider = MusicChartRepositoryProvider._();

final class MusicChartRepositoryProvider
    extends
        $FunctionalProvider<
          MusicChartRepository,
          MusicChartRepository,
          MusicChartRepository
        >
    with $Provider<MusicChartRepository> {
  MusicChartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicChartRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicChartRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusicChartRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicChartRepository create(Ref ref) {
    return musicChartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicChartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicChartRepository>(value),
    );
  }
}

String _$musicChartRepositoryHash() =>
    r'1bda9568e33bc036117c8fa1ecf1ef6c24f1d328';

@ProviderFor(MusicChartController)
final musicChartControllerProvider = MusicChartControllerProvider._();

final class MusicChartControllerProvider
    extends $NotifierProvider<MusicChartController, MusicChartState> {
  MusicChartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicChartControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicChartControllerHash();

  @$internal
  @override
  MusicChartController create() => MusicChartController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicChartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicChartState>(value),
    );
  }
}

String _$musicChartControllerHash() =>
    r'e3835c99f71bdc52b8b925fc79d87b26d91820ee';

abstract class _$MusicChartController extends $Notifier<MusicChartState> {
  MusicChartState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MusicChartState, MusicChartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MusicChartState, MusicChartState>,
              MusicChartState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
