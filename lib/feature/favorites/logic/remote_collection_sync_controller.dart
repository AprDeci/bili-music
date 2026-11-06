import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/remote_collection_sync_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_collection_sync_controller.g.dart';

@riverpod
class RemoteCollectionSyncController extends _$RemoteCollectionSyncController {
  static const Duration _staleThreshold = Duration(minutes: 5);
  static const Duration _successStatusDuration = Duration(milliseconds: 350);

  final AppLogger _logger = AppLogger('RemoteCollectionSyncController');

  Future<void>? _inFlight;
  Timer? _statusTimer;

  @override
  RemoteCollectionSyncState build(String collectionId) {
    ref.onDispose(() {
      _statusTimer?.cancel();
    });
    return const RemoteCollectionSyncState();
  }

  Future<void> sync({bool force = false}) {
    final Future<void>? existing = _inFlight;
    if (existing != null) {
      return existing;
    }
    final Future<void> future = _runSync(force: force);
    _inFlight = future;
    return future.whenComplete(() {
      _inFlight = null;
    });
  }

  Future<void> _runSync({required bool force}) async {
    final FavoriteCollection? collection = _collection();
    if (collection == null || !collection.isRemote) {
      return;
    }
    final DateTime? lastSyncedAt = collection.lastSyncedAt;
    if (!force &&
        lastSyncedAt != null &&
        DateTime.now().difference(lastSyncedAt) <= _staleThreshold) {
      return;
    }

    _statusTimer?.cancel();
    state = state.copyWith(status: RemoteCollectionSyncStatus.syncing);
    try {
      final RemoteCollectionSyncResult result = await ref
          .read(favoritesControllerProvider.notifier)
          .syncRemoteCollectionIfStale(collection.id, force: force);
      if (!ref.mounted) {
        return;
      }
      switch (result) {
        case RemoteCollectionSyncResult.skipped:
          state = state.copyWith(status: null);
        case RemoteCollectionSyncResult.incomplete:
          state = state.copyWith(status: RemoteCollectionSyncStatus.failure);
          ToastUtil.show('同步未完成，已使用本地数据');
        case RemoteCollectionSyncResult.completed:
          state = state.copyWith(status: RemoteCollectionSyncStatus.success);
          _clearStatusAfter(_successStatusDuration);
      }
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) {
        return;
      }
      _logger.w('Failed to sync remote collection', error, stackTrace);
      state = state.copyWith(status: RemoteCollectionSyncStatus.failure);
      ToastUtil.show('网络歌单同步失败，请稍后重试');
    }
  }

  void _clearStatusAfter(Duration duration) {
    _statusTimer?.cancel();
    _statusTimer = Timer(duration, () {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(status: null);
    });
  }

  FavoriteCollection? _collection() {
    for (final FavoriteCollection collection
        in ref.read(favoritesControllerProvider).collections) {
      if (collection.id == collectionId) {
        return collection;
      }
    }
    return null;
  }
}
