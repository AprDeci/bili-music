// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_entry_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoriteEntryMetadata)
final favoriteEntryMetadataProvider = FavoriteEntryMetadataFamily._();

final class FavoriteEntryMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Metadata?>,
          Metadata?,
          FutureOr<Metadata?>
        >
    with $FutureModifier<Metadata?>, $FutureProvider<Metadata?> {
  FavoriteEntryMetadataProvider._({
    required FavoriteEntryMetadataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'favoriteEntryMetadataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoriteEntryMetadataHash();

  @override
  String toString() {
    return r'favoriteEntryMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Metadata?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Metadata?> create(Ref ref) {
    final argument = this.argument as String;
    return favoriteEntryMetadata(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteEntryMetadataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoriteEntryMetadataHash() =>
    r'3dc67195f557c48ce16540e930357ba1dae2b196';

final class FavoriteEntryMetadataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Metadata?>, String> {
  FavoriteEntryMetadataFamily._()
    : super(
        retry: null,
        name: r'favoriteEntryMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FavoriteEntryMetadataProvider call(String contentId) =>
      FavoriteEntryMetadataProvider._(argument: contentId, from: this);

  @override
  String toString() => r'favoriteEntryMetadataProvider';
}

@ProviderFor(favoriteEntryCoverUrl)
final favoriteEntryCoverUrlProvider = FavoriteEntryCoverUrlFamily._();

final class FavoriteEntryCoverUrlProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  FavoriteEntryCoverUrlProvider._({
    required FavoriteEntryCoverUrlFamily super.from,
    required (String, FavoriteEntry?) super.argument,
  }) : super(
         retry: null,
         name: r'favoriteEntryCoverUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoriteEntryCoverUrlHash();

  @override
  String toString() {
    return r'favoriteEntryCoverUrlProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as (String, FavoriteEntry?);
    return favoriteEntryCoverUrl(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteEntryCoverUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoriteEntryCoverUrlHash() =>
    r'e9b3d7f9b8ed23951587a5092da465ffaa064028';

final class FavoriteEntryCoverUrlFamily extends $Family
    with $FunctionalFamilyOverride<String?, (String, FavoriteEntry?)> {
  FavoriteEntryCoverUrlFamily._()
    : super(
        retry: null,
        name: r'favoriteEntryCoverUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FavoriteEntryCoverUrlProvider call(
    String collectionId,
    FavoriteEntry? entry,
  ) => FavoriteEntryCoverUrlProvider._(
    argument: (collectionId, entry),
    from: this,
  );

  @override
  String toString() => r'favoriteEntryCoverUrlProvider';
}
