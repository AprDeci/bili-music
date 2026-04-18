// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webdav_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webDavRepository)
final webDavRepositoryProvider = WebDavRepositoryProvider._();

final class WebDavRepositoryProvider
    extends
        $FunctionalProvider<
          WebDavRepository,
          WebDavRepository,
          WebDavRepository
        >
    with $Provider<WebDavRepository> {
  WebDavRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webDavRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webDavRepositoryHash();

  @$internal
  @override
  $ProviderElement<WebDavRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebDavRepository create(Ref ref) {
    return webDavRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebDavRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebDavRepository>(value),
    );
  }
}

String _$webDavRepositoryHash() => r'e82cf0e55a4308f6ce57792796f52297bf7aa70f';
