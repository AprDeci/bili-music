// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bili_chapter_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliChapterRepository)
final biliChapterRepositoryProvider = BiliChapterRepositoryProvider._();

final class BiliChapterRepositoryProvider
    extends
        $FunctionalProvider<
          BiliChapterRepository,
          BiliChapterRepository,
          BiliChapterRepository
        >
    with $Provider<BiliChapterRepository> {
  BiliChapterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliChapterRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliChapterRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliChapterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliChapterRepository create(Ref ref) {
    return biliChapterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliChapterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliChapterRepository>(value),
    );
  }
}

String _$biliChapterRepositoryHash() =>
    r'288f643cdd2775de2a31f42c55ac8df48eec11fa';
