// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(downloadRepository)
final downloadRepositoryProvider = DownloadRepositoryProvider._();

final class DownloadRepositoryProvider
    extends
        $FunctionalProvider<
          DownloadRepository,
          DownloadRepository,
          DownloadRepository
        >
    with $Provider<DownloadRepository> {
  DownloadRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadRepositoryHash();

  @$internal
  @override
  $ProviderElement<DownloadRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DownloadRepository create(Ref ref) {
    return downloadRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadRepository>(value),
    );
  }
}

String _$downloadRepositoryHash() =>
    r'16ae6a55d9b64633892ef532161c54253f657f10';
