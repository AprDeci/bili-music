// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadController)
final downloadControllerProvider = DownloadControllerProvider._();

final class DownloadControllerProvider
    extends $NotifierProvider<DownloadController, DownloadState> {
  DownloadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadControllerHash();

  @$internal
  @override
  DownloadController create() => DownloadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadState>(value),
    );
  }
}

String _$downloadControllerHash() =>
    r'43ff19369a93e7925d69c183582cb100665c40ab';

abstract class _$DownloadController extends $Notifier<DownloadState> {
  DownloadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DownloadState, DownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DownloadState, DownloadState>,
              DownloadState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
