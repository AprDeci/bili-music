import 'dart:async';

import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_online_audience_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerOnlineAudienceController extends _$PlayerOnlineAudienceController {
  static const Duration _pollInterval = Duration(seconds: 30);

  late final BiliPlayerRepository _repository = ref.read(
    biliPlayerRepositoryProvider,
  );

  Timer? _pollTimer;
  String? _currentStableId;
  PlayerOnlineAudience? _lastSuccessValue;
  bool _isFetching = false;

  @override
  FutureOr<PlayerOnlineAudience?> build() async {
    ref.onDispose(_disposeResources);

    ref.listen<PlayerState>(playerControllerProvider, (
      PlayerState? previous,
      PlayerState next,
    ) {
      final PlayableItem? previousItem = previous?.currentItem;
      final PlayableItem? nextItem = next.currentItem;
      if (previousItem?.stableId == nextItem?.stableId) {
        return;
      }
      unawaited(_handleCurrentItemChanged(nextItem));
    }, fireImmediately: true);

    return null;
  }

  Future<void> refresh() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    await _fetchForItem(item, preserveLastValueOnError: true);
  }

  Future<void> _handleCurrentItemChanged(PlayableItem? item) async {
    _cancelPolling();

    if (!_canFetch(item)) {
      _currentStableId = null;
      _lastSuccessValue = null;
      state = const AsyncData<PlayerOnlineAudience?>(null);
      return;
    }

    _currentStableId = item!.stableId;
    _lastSuccessValue = null;
    state = const AsyncLoading<PlayerOnlineAudience?>();

    await _fetchForItem(item, preserveLastValueOnError: false);
    if (_currentStableId == item.stableId) {
      _startPolling(item);
    }
  }

  Future<void> _fetchForItem(
    PlayableItem? item, {
    required bool preserveLastValueOnError,
  }) async {
    if (!_canFetch(item) || _isFetching) {
      return;
    }

    final String stableId = item!.stableId;
    _isFetching = true;
    try {
      final PlayerOnlineAudience audience = await _repository
          .fetchOnlineAudience(cid: item.cid!, aid: item.aid, bvid: item.bvid);
      if (_currentStableId != stableId || !ref.mounted) {
        return;
      }
      _lastSuccessValue = audience;
      state = AsyncData<PlayerOnlineAudience?>(audience);
    } on Object catch (error, stackTrace) {
      if (_currentStableId != stableId || !ref.mounted) {
        return;
      }
      if (preserveLastValueOnError && _lastSuccessValue != null) {
        state = AsyncData<PlayerOnlineAudience?>(_lastSuccessValue);
      } else {
        state = AsyncError<PlayerOnlineAudience?>(error, stackTrace);
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _canFetch(PlayableItem? item) {
    final int? cid = item?.cid;
    if (item == null || cid == null || cid <= 0) {
      return false;
    }
    return item.aid > 0 || item.bvid.isNotEmpty;
  }

  void _startPolling(PlayableItem item) {
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_fetchForItem(item, preserveLastValueOnError: true));
    });
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _disposeResources() {
    _cancelPolling();
  }
}
