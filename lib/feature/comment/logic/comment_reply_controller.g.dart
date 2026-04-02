// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_reply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentReplyController)
final commentReplyControllerProvider = CommentReplyControllerFamily._();

final class CommentReplyControllerProvider
    extends $NotifierProvider<CommentReplyController, CommentReplyState> {
  CommentReplyControllerProvider._({
    required CommentReplyControllerFamily super.from,
    required CommentReplySheetArgs super.argument,
  }) : super(
         retry: null,
         name: r'commentReplyControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentReplyControllerHash();

  @override
  String toString() {
    return r'commentReplyControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentReplyController create() => CommentReplyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentReplyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentReplyState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentReplyControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentReplyControllerHash() =>
    r'd76773197b5ad3b07dbc140c67c4b211eab3a5b4';

final class CommentReplyControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentReplyController,
          CommentReplyState,
          CommentReplyState,
          CommentReplyState,
          CommentReplySheetArgs
        > {
  CommentReplyControllerFamily._()
    : super(
        retry: null,
        name: r'commentReplyControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentReplyControllerProvider call(CommentReplySheetArgs args) =>
      CommentReplyControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'commentReplyControllerProvider';
}

abstract class _$CommentReplyController extends $Notifier<CommentReplyState> {
  late final _$args = ref.$arg as CommentReplySheetArgs;
  CommentReplySheetArgs get args => _$args;

  CommentReplyState build(CommentReplySheetArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CommentReplyState, CommentReplyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommentReplyState, CommentReplyState>,
              CommentReplyState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
