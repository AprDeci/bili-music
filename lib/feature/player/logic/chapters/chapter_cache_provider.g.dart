// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chapterCacheRepository)
final chapterCacheRepositoryProvider = ChapterCacheRepositoryProvider._();

final class ChapterCacheRepositoryProvider
    extends
        $FunctionalProvider<
          ChapterCacheRepository,
          ChapterCacheRepository,
          ChapterCacheRepository
        >
    with $Provider<ChapterCacheRepository> {
  ChapterCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterCacheRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChapterCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChapterCacheRepository create(Ref ref) {
    return chapterCacheRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterCacheRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterCacheRepository>(value),
    );
  }
}

String _$chapterCacheRepositoryHash() =>
    r'badacced9c5ea41fe391bccd3284dbf32ab7b31b';

@ProviderFor(itemIsCompilation)
final itemIsCompilationProvider = ItemIsCompilationFamily._();

final class ItemIsCompilationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  ItemIsCompilationProvider._({
    required ItemIsCompilationFamily super.from,
    required PlayableItem super.argument,
  }) : super(
         retry: null,
         name: r'itemIsCompilationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemIsCompilationHash();

  @override
  String toString() {
    return r'itemIsCompilationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as PlayableItem;
    return itemIsCompilation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemIsCompilationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemIsCompilationHash() => r'84bc905edadea0502e00615412672bd1a81b546f';

final class ItemIsCompilationFamily extends $Family
    with $FunctionalFamilyOverride<bool, PlayableItem> {
  ItemIsCompilationFamily._()
    : super(
        retry: null,
        name: r'itemIsCompilationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemIsCompilationProvider call(PlayableItem item) =>
      ItemIsCompilationProvider._(argument: item, from: this);

  @override
  String toString() => r'itemIsCompilationProvider';
}
