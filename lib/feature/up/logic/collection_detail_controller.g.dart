// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollectionDetailController)
final collectionDetailControllerProvider = CollectionDetailControllerFamily._();

final class CollectionDetailControllerProvider
    extends
        $AsyncNotifierProvider<
          CollectionDetailController,
          CollectionDetailState
        > {
  CollectionDetailControllerProvider._({
    required CollectionDetailControllerFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'collectionDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionDetailControllerHash();

  @override
  String toString() {
    return r'collectionDetailControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CollectionDetailController create() => CollectionDetailController();

  @override
  bool operator ==(Object other) {
    return other is CollectionDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionDetailControllerHash() =>
    r'9ef30fff6ca78ef1613ac9b428df2adcac884f7c';

final class CollectionDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CollectionDetailController,
          AsyncValue<CollectionDetailState>,
          CollectionDetailState,
          FutureOr<CollectionDetailState>,
          (int, int)
        > {
  CollectionDetailControllerFamily._()
    : super(
        retry: null,
        name: r'collectionDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionDetailControllerProvider call(int mid, int seasonId) =>
      CollectionDetailControllerProvider._(
        argument: (mid, seasonId),
        from: this,
      );

  @override
  String toString() => r'collectionDetailControllerProvider';
}

abstract class _$CollectionDetailController
    extends $AsyncNotifier<CollectionDetailState> {
  late final _$args = ref.$arg as (int, int);
  int get mid => _$args.$1;
  int get seasonId => _$args.$2;

  FutureOr<CollectionDetailState> build(int mid, int seasonId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CollectionDetailState>, CollectionDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CollectionDetailState>,
                CollectionDetailState
              >,
              AsyncValue<CollectionDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
