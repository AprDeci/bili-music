// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bilibili_comment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliCommentRepository)
final biliCommentRepositoryProvider = BiliCommentRepositoryProvider._();

final class BiliCommentRepositoryProvider
    extends
        $FunctionalProvider<
          BiliCommentRepository,
          BiliCommentRepository,
          BiliCommentRepository
        >
    with $Provider<BiliCommentRepository> {
  BiliCommentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliCommentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliCommentRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliCommentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BiliCommentRepository create(Ref ref) {
    return biliCommentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliCommentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliCommentRepository>(value),
    );
  }
}

String _$biliCommentRepositoryHash() =>
    r'ca41ba26d7aaa845b391f3e2188b4fc354ecf552';
