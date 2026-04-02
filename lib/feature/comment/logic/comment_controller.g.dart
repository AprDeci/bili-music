// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentController)
final commentControllerProvider = CommentControllerFamily._();

final class CommentControllerProvider
    extends $NotifierProvider<CommentController, CommentState> {
  CommentControllerProvider._({
    required CommentControllerFamily super.from,
    required CommentTarget super.argument,
  }) : super(
         retry: null,
         name: r'commentControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentControllerHash();

  @override
  String toString() {
    return r'commentControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentController create() => CommentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentControllerHash() => r'cba3586a2ee428f1d83bc210af8710a542362370';

final class CommentControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentController,
          CommentState,
          CommentState,
          CommentState,
          CommentTarget
        > {
  CommentControllerFamily._()
    : super(
        retry: null,
        name: r'commentControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentControllerProvider call(CommentTarget target) =>
      CommentControllerProvider._(argument: target, from: this);

  @override
  String toString() => r'commentControllerProvider';
}

abstract class _$CommentController extends $Notifier<CommentState> {
  late final _$args = ref.$arg as CommentTarget;
  CommentTarget get target => _$args;

  CommentState build(CommentTarget target);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CommentState, CommentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommentState, CommentState>,
              CommentState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
