// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_lyrics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DesktopLyricsController)
final desktopLyricsControllerProvider = DesktopLyricsControllerProvider._();

final class DesktopLyricsControllerProvider
    extends $NotifierProvider<DesktopLyricsController, bool> {
  DesktopLyricsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopLyricsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopLyricsControllerHash();

  @$internal
  @override
  DesktopLyricsController create() => DesktopLyricsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$desktopLyricsControllerHash() =>
    r'1c229b6d9261e964e007fc5ec8dbf499ae96467f';

abstract class _$DesktopLyricsController extends $Notifier<bool> {
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
