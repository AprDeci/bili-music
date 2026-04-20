// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meting_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metingRepository)
final metingRepositoryProvider = MetingRepositoryProvider._();

final class MetingRepositoryProvider
    extends
        $FunctionalProvider<
          MetingRepository,
          MetingRepository,
          MetingRepository
        >
    with $Provider<MetingRepository> {
  MetingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metingRepositoryHash();

  @$internal
  @override
  $ProviderElement<MetingRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MetingRepository create(Ref ref) {
    return metingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetingRepository>(value),
    );
  }
}

String _$metingRepositoryHash() => r'b731d16218dd0d349b2adffdba5bffd0c8858956';
