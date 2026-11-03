enum RemoteCollectionSyncStatus { syncing, success, failure }

class RemoteCollectionSyncState {
  const RemoteCollectionSyncState({
    this.status,
    this.isLoadingMore = false,
    this.hasMoreRemotePages = true,
    this.nextPage = 2,
  });

  static const Object _unset = Object();

  final RemoteCollectionSyncStatus? status;
  final bool isLoadingMore;
  final bool hasMoreRemotePages;
  final int nextPage;

  bool get isSyncing => status == RemoteCollectionSyncStatus.syncing;

  bool get hasFailed => status == RemoteCollectionSyncStatus.failure;

  RemoteCollectionSyncState copyWith({
    Object? status = _unset,
    bool? isLoadingMore,
    bool? hasMoreRemotePages,
    int? nextPage,
  }) {
    return RemoteCollectionSyncState(
      status: identical(status, _unset)
          ? this.status
          : status as RemoteCollectionSyncStatus?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreRemotePages: hasMoreRemotePages ?? this.hasMoreRemotePages,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  RemoteCollectionSyncState withPagination({
    required bool hasMore,
    required int nextPage,
    bool isLoadingMore = false,
  }) {
    return copyWith(
      hasMoreRemotePages: hasMore,
      nextPage: nextPage,
      isLoadingMore: isLoadingMore,
    );
  }
}
