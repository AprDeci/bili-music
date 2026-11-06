// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_collection_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RemoteCollectionSyncController)
final remoteCollectionSyncControllerProvider =
    RemoteCollectionSyncControllerFamily._();

final class RemoteCollectionSyncControllerProvider
    extends
        $NotifierProvider<
          RemoteCollectionSyncController,
          RemoteCollectionSyncState
        > {
  RemoteCollectionSyncControllerProvider._({
    required RemoteCollectionSyncControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'remoteCollectionSyncControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteCollectionSyncControllerHash();

  @override
  String toString() {
    return r'remoteCollectionSyncControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RemoteCollectionSyncController create() => RemoteCollectionSyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteCollectionSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteCollectionSyncState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteCollectionSyncControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteCollectionSyncControllerHash() =>
    r'0fb83ace679cc1622e6436686c85b5700b267f6b';

final class RemoteCollectionSyncControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RemoteCollectionSyncController,
          RemoteCollectionSyncState,
          RemoteCollectionSyncState,
          RemoteCollectionSyncState,
          String
        > {
  RemoteCollectionSyncControllerFamily._()
    : super(
        retry: null,
        name: r'remoteCollectionSyncControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RemoteCollectionSyncControllerProvider call(String collectionId) =>
      RemoteCollectionSyncControllerProvider._(
        argument: collectionId,
        from: this,
      );

  @override
  String toString() => r'remoteCollectionSyncControllerProvider';
}

abstract class _$RemoteCollectionSyncController
    extends $Notifier<RemoteCollectionSyncState> {
  late final _$args = ref.$arg as String;
  String get collectionId => _$args;

  RemoteCollectionSyncState build(String collectionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<RemoteCollectionSyncState, RemoteCollectionSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RemoteCollectionSyncState, RemoteCollectionSyncState>,
              RemoteCollectionSyncState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
