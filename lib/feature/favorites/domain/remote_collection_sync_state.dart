enum RemoteCollectionSyncStatus { syncing, success, failure }

class RemoteCollectionSyncState {
  const RemoteCollectionSyncState({this.status});

  static const Object _unset = Object();

  final RemoteCollectionSyncStatus? status;

  bool get isSyncing => status == RemoteCollectionSyncStatus.syncing;

  bool get hasFailed => status == RemoteCollectionSyncStatus.failure;

  RemoteCollectionSyncState copyWith({Object? status = _unset}) {
    return RemoteCollectionSyncState(
      status: identical(status, _unset)
          ? this.status
          : status as RemoteCollectionSyncStatus?,
    );
  }
}
