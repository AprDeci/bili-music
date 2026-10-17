// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_lookup_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metadataLookupService)
final metadataLookupServiceProvider = MetadataLookupServiceProvider._();

final class MetadataLookupServiceProvider
    extends
        $FunctionalProvider<
          MetadataLookupService,
          MetadataLookupService,
          MetadataLookupService
        >
    with $Provider<MetadataLookupService> {
  MetadataLookupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metadataLookupServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metadataLookupServiceHash();

  @$internal
  @override
  $ProviderElement<MetadataLookupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MetadataLookupService create(Ref ref) {
    return metadataLookupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetadataLookupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetadataLookupService>(value),
    );
  }
}

String _$metadataLookupServiceHash() =>
    r'de35490ecd6cab27bb097b3f5de72d0368e059ec';
