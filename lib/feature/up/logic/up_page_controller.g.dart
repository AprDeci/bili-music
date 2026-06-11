// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'up_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biliUpRepository)
final biliUpRepositoryProvider = BiliUpRepositoryProvider._();

final class BiliUpRepositoryProvider
    extends
        $FunctionalProvider<
          BiliUpRepository,
          BiliUpRepository,
          BiliUpRepository
        >
    with $Provider<BiliUpRepository> {
  BiliUpRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biliUpRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biliUpRepositoryHash();

  @$internal
  @override
  $ProviderElement<BiliUpRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiliUpRepository create(Ref ref) {
    return biliUpRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiliUpRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiliUpRepository>(value),
    );
  }
}

String _$biliUpRepositoryHash() => r'1e26f7b9f59090867632d7d11cd4ee77c1401820';

@ProviderFor(UpPageController)
final upPageControllerProvider = UpPageControllerFamily._();

final class UpPageControllerProvider
    extends $AsyncNotifierProvider<UpPageController, UpPageState> {
  UpPageControllerProvider._({
    required UpPageControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'upPageControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$upPageControllerHash();

  @override
  String toString() {
    return r'upPageControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UpPageController create() => UpPageController();

  @override
  bool operator ==(Object other) {
    return other is UpPageControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$upPageControllerHash() => r'8876abaa3bea0ada8a8c7e22c435f5f347471ad8';

final class UpPageControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          UpPageController,
          AsyncValue<UpPageState>,
          UpPageState,
          FutureOr<UpPageState>,
          int
        > {
  UpPageControllerFamily._()
    : super(
        retry: null,
        name: r'upPageControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpPageControllerProvider call(int mid) =>
      UpPageControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'upPageControllerProvider';
}

abstract class _$UpPageController extends $AsyncNotifier<UpPageState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  FutureOr<UpPageState> build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpPageState>, UpPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpPageState>, UpPageState>,
              AsyncValue<UpPageState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
