import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/listening/data/bili_history_remote_repository.dart';
import 'package:bilimusic/feature/listening/data/listening_progress_local_repository.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listening_progress_controller.g.dart';

@Riverpod(keepAlive: true)
ListeningProgressLocalRepository listeningProgressLocalRepository(Ref ref) =>
    ListeningProgressLocalRepository(
      Hive.box<String>(listeningProgressBoxName),
    );

@Riverpod(keepAlive: true)
BiliHistoryRemoteRepository biliHistoryRemoteRepository(Ref ref) =>
    BiliHistoryRemoteRepository(ref.read(biliClientProvider.notifier));

@Riverpod(keepAlive: true)
class ListeningProgressController extends _$ListeningProgressController
    with WidgetsBindingObserver {
  static final AppLogger _logger = AppLogger('ListeningProgress');
  late final ListeningProgressLocalRepository _local = ref.read(
    listeningProgressLocalRepositoryProvider,
  );
  late final BiliHistoryRemoteRepository _remote = ref.read(
    biliHistoryRemoteRepositoryProvider,
  );
  Future<void> _writes = Future.value();
  Future<void> _reports = Future.value();
  int _sessionGeneration = 0;
  int _resumeGeneration = 0;
  final Set<String> _scheduled = {};
  final Set<String> _freshKeys = {};
  final Map<String, ({ListeningProgress local, ListeningProgress remote})>
  _conflicts = {};
  Timer? _retryTimer;
  PlayableItem? _item;
  String? _accountId;
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _completed = false;
  bool _hasPlayed = false;
  bool _dirty = false;
  bool _playing = false;
  DateTime? _lastSavedAt;

  BiliSession? get _session => ref.read(biliSessionControllerProvider);
  String get accountId =>
      _session?.isLoggedIn == true ? _session!.dedeUserId : 'guest';

  @override
  ListeningState build() {
    final StreamSubscription<PlayerEvent> subscription = ref
        .read(playerEventHubProvider)
        .events
        .listen(onEvent);
    WidgetsBinding.instance.addObserver(this);
    ref.listen(biliSessionControllerProvider, (previous, next) {
      if (previous?.dedeUserId != next?.dedeUserId ||
          previous?.isLoggedIn != next?.isLoggedIn) {
        unawaited(_capture(accountChanged: true));
        _sessionGeneration++;
        _resumeGeneration++;
        _item = null;
        _hasPlayed = false;
        _dirty = false;
        _playing = false;
        _freshKeys.clear();
        _conflicts.clear();
        state = const ListeningState();
        Future<void>.microtask(flush);
      }
    });
    _retryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(flush()),
    );
    ref.onDispose(() {
      _retryTimer?.cancel();
      unawaited(subscription.cancel());
      WidgetsBinding.instance.removeObserver(this);
    });
    return const ListeningState();
  }

  void begin(PlayableItem item, Duration position, Duration? duration) {
    _item = item.isSpoken ? item : null;
    _accountId = accountId;
    _position = position;
    _duration = duration;
    _completed = false;
    _hasPlayed = false;
    _dirty = false;
    _playing = false;
    _lastSavedAt = null;
  }

  Future<void> suspend() async {
    final Future<void> saved = _capture();
    _item = null;
    _playing = false;
    await saved;
  }

  void onEvent(PlayerEvent event) {
    final PlayableItem? item = _item;
    if (item == null ||
        event.item?.isSpoken != true ||
        event.item?.stableId != item.stableId ||
        event.item?.collectionId != item.collectionId ||
        _accountId != accountId) {
      return;
    }
    if (event.type == PlayerEventType.trackChanged) return;
    if (event.type == PlayerEventType.duration) _duration = event.duration;
    if (event.type == PlayerEventType.playbackState) {
      _playing = event.isPlaying;
      if (_playing && !_hasPlayed) _dirty = true;
      _hasPlayed = _hasPlayed || _playing;
    }
    if (event.type == PlayerEventType.position ||
        event.type == PlayerEventType.seek) {
      if (_completed && event.type == PlayerEventType.position) return;
      if (!_hasPlayed && event.type != PlayerEventType.seek) return;
      if (_position != event.position) _dirty = true;
      _position = event.position;
      _completed = false;
    }
    if (event.type == PlayerEventType.seek) {
      _hasPlayed = true;
      _dirty = true;
    }
    if (event.type == PlayerEventType.completed) {
      _completed = true;
      _dirty = true;
      _hasPlayed = true;
      _position = event.duration ?? _position;
    }
    if (event.type == PlayerEventType.seek ||
        event.type == PlayerEventType.stop ||
        event.type == PlayerEventType.completed ||
        (event.type == PlayerEventType.playbackState && !event.isPlaying)) {
      unawaited(_capture());
    } else if (event.type == PlayerEventType.position &&
        _playing &&
        (_lastSavedAt == null ||
            DateTime.now().difference(_lastSavedAt!) >=
                const Duration(seconds: 15))) {
      unawaited(_capture());
    }
  }

  Future<void> _capture({bool accountChanged = false}) {
    final PlayableItem? item = _item;
    if (item == null ||
        !_hasPlayed ||
        !_dirty ||
        (item.cid ?? 0) <= 0 ||
        (!accountChanged && _accountId != accountId) ||
        _conflicts.values.any(
          (conflict) => conflict.local.matchesChapter(item),
        )) {
      return _writes;
    }
    final DateTime now = DateTime.now();
    final int sessionGeneration = _sessionGeneration;
    _lastSavedAt = now;
    _dirty = false;
    final ListeningProgress progress = ListeningProgress(
      accountId: _accountId!,
      aid: item.aid,
      bvid: item.bvid,
      cid: item.cid!,
      page: item.page ?? 1,
      collectionId: item.collectionId,
      positionMs: _position.inMilliseconds.clamp(0, 1 << 53),
      durationMs: _duration?.inMilliseconds ?? 0,
      updatedAtMs: now.millisecondsSinceEpoch,
      completed: _completed,
      pendingSync: _accountId != 'guest',
    );
    _freshKeys.add(progress.key);
    _writes = _writes
        .then((_) async {
          await _local.save(progress);
          if (progress.pendingSync) _scheduleReport(progress);
        })
        .catchError((Object error, StackTrace stack) {
          _logger.w('save failed', error, stack);
          if (_isCurrentSession(sessionGeneration, progress.accountId)) {
            if (_item != null && progress.matchesChapter(_item!)) _dirty = true;
            state = state.copyWith(warning: '收听进度保存失败');
          }
        });
    return _writes;
  }

  bool _isCurrentSession(int generation, String account) =>
      ref.mounted && generation == _sessionGeneration && account == accountId;

  ListeningProgress? _readProgress(ListeningProgress progress) =>
      _local.readChapter(
        accountId: progress.accountId,
        aid: progress.aid,
        bvid: progress.bvid,
        cid: progress.cid,
      );

  Future<bool> _importProgress(
    ListeningProgress progress,
    ListeningProgress? expected, {
    required bool Function() isCurrent,
    bool resolvingConflict = false,
  }) {
    final Future<bool> saved = _writes.then((_) async {
      if (!isCurrent() ||
          _readProgress(progress) != expected ||
          (!resolvingConflict &&
              (_conflicts.containsKey(progress.key) ||
                  _conflicts.containsKey(expected?.key)))) {
        return false;
      }
      await _local.save(progress);
      return isCurrent();
    });
    _writes = saved.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return saved;
  }

  void _showConflict(ListeningProgress local, ListeningProgress remote) {
    _conflicts.putIfAbsent(local.key, () => (local: local, remote: remote));
    if (state.localConflict != null) return;
    state = state.copyWith(
      warning: '本地和B站收听进度不同，请选择要继续的位置',
      localConflict: local,
      remoteConflict: remote,
    );
  }

  void _scheduleReport(ListeningProgress progress) {
    if (!_scheduled.add(progress.key)) return;
    final int sessionGeneration = _sessionGeneration;
    bool isCurrent() =>
        _isCurrentSession(sessionGeneration, progress.accountId);
    _reports = _reports
        .then((_) async {
          if (!isCurrent()) return;
          final BiliSession? session = _session;
          if (session == null || !session.isLoggedIn) return;
          final ListeningProgress? latest = _readProgress(progress);
          if (latest == null ||
              !latest.pendingSync ||
              _conflicts.containsKey(latest.key)) {
            return;
          }
          final PlayableItem item = PlayableItem(
            aid: latest.aid,
            bvid: latest.bvid,
            cid: latest.cid,
            page: latest.page,
            title: '',
            author: '',
            coverUrl: '',
          );
          if (!_freshKeys.contains(latest.key)) {
            final List<ListeningProgress> recent = await _remote.fetchRecent(
              session,
            );
            await _writes;
            if (!isCurrent() ||
                _conflicts.containsKey(latest.key) ||
                _readProgress(latest) != latest) {
              return;
            }
            final ListeningProgress? remote = recent
                .where((p) => p.matchesChapter(item))
                .firstOrNull;
            if (remote != null && remote.updatedAtMs > latest.updatedAtMs) {
              await _importProgress(
                remote.copyWith(
                  collectionId: latest.collectionId,
                  page: latest.page,
                ),
                latest,
                isCurrent: isCurrent,
              );
              return;
            }
            if (remote == null) {
              final ListeningProgress? remotePosition = await _remote
                  .fetchProgress(item, session);
              await _writes;
              if (!isCurrent() ||
                  _conflicts.containsKey(latest.key) ||
                  _readProgress(latest) != latest) {
                return;
              }
              if (remotePosition != null &&
                  remotePosition.matchesChapter(item) &&
                  (remotePosition.positionMs != latest.positionMs ||
                      remotePosition.completed != latest.completed)) {
                _showConflict(latest, remotePosition);
                return;
              }
            }
          }
          if (!isCurrent() ||
              _conflicts.containsKey(latest.key) ||
              _readProgress(latest) != latest) {
            return;
          }
          await _remote.report(latest, session);
          await _importProgress(
            latest.copyWith(pendingSync: false),
            latest,
            isCurrent: () => ref.mounted,
          );
          if (isCurrent() && state.localConflict == null) {
            state = state.copyWith(warning: null);
          }
        })
        .catchError((Object error, StackTrace stack) {
          _logger.d('history sync failed');
          if (isCurrent()) {
            state = state.copyWith(warning: '历史同步失败，进度已保存在本地，将自动重试');
          }
        })
        .whenComplete(() => _scheduled.remove(progress.key));
  }

  Future<Duration?> resolveConflict({
    required bool useLocal,
    ListeningProgress? expectedLocal,
    ListeningProgress? expectedRemote,
  }) async {
    final ListeningProgress? local = state.localConflict;
    final ListeningProgress? remote = state.remoteConflict;
    if (local == null ||
        remote == null ||
        local.accountId != accountId ||
        (expectedLocal != null && expectedLocal != local) ||
        (expectedRemote != null && expectedRemote != remote)) {
      return null;
    }
    final int sessionGeneration = _sessionGeneration;
    final ListeningProgress chosen = (useLocal ? local : remote).copyWith(
      collectionId: local.collectionId,
      page: local.page,
      updatedAtMs: useLocal
          ? DateTime.now().millisecondsSinceEpoch
          : remote.updatedAtMs,
      pendingSync: useLocal,
    );
    final bool saved = await _importProgress(
      chosen,
      local,
      resolvingConflict: true,
      isCurrent: () =>
          _isCurrentSession(sessionGeneration, local.accountId) &&
          state.localConflict == local &&
          state.remoteConflict == remote,
    );
    if (!saved) return null;
    if (_item != null && chosen.matchesChapter(_item!)) {
      _position = chosen.resumePosition;
      _completed = chosen.completed;
      _dirty = false;
    }
    _conflicts.remove(local.key);
    final next = _conflicts.values.firstOrNull;
    state = state.copyWith(
      warning: next == null ? null : '本地和B站收听进度不同，请选择要继续的位置',
      localConflict: next?.local,
      remoteConflict: next?.remote,
    );
    if (useLocal) {
      _freshKeys.add(chosen.key);
      _scheduleReport(chosen);
    }
    return chosen.resumePosition;
  }

  Future<void> flush() async {
    await _capture();
    if (!ref.mounted) return;
    final String account = accountId;
    if (account == 'guest') return;
    for (final ListeningProgress progress
        in _local.load(account).where((p) => p.pendingSync)) {
      _scheduleReport(progress);
    }
    await _reports;
  }

  Future<Duration> resumePosition(
    PlayableItem item, {
    Duration fallback = Duration.zero,
    bool Function()? isCurrent,
  }) async {
    final int requestGeneration = ++_resumeGeneration;
    final int sessionGeneration = _sessionGeneration;
    final String account = accountId;
    bool isActive() =>
        _isCurrentSession(sessionGeneration, account) &&
        requestGeneration == _resumeGeneration &&
        (isCurrent?.call() ?? true);
    ListeningProgress? readLocal() => _local.readChapter(
      accountId: account,
      aid: item.aid,
      bvid: item.bvid,
      cid: item.cid ?? 0,
    );
    await _writes;
    if (!isActive()) return Duration.zero;
    final BiliSession? session = _session;
    final ListeningProgress? local = readLocal();
    final conflict = _conflicts.values
        .where((c) => c.local.matchesChapter(item))
        .firstOrNull;
    if (conflict != null) return conflict.remote.resumePosition;
    if (session == null || !session.isLoggedIn) {
      return local?.resumePosition ?? fallback;
    }
    try {
      if (local?.pendingSync ?? false) {
        final List<ListeningProgress> recent = await _remote.fetchRecent(
          session,
        );
        await _writes;
        if (!isActive()) return Duration.zero;
        if (readLocal() != local) {
          return readLocal()?.resumePosition ?? fallback;
        }
        final ListeningProgress? remote = recent
            .where((p) => p.matchesChapter(item))
            .firstOrNull;
        if (remote != null && remote.updatedAtMs > local!.updatedAtMs) {
          final ListeningProgress result = remote.copyWith(
            page: item.page ?? remote.page,
            collectionId: item.collectionId,
          );
          if (await _importProgress(result, local, isCurrent: isActive)) {
            return result.resumePosition;
          }
          return isActive()
              ? readLocal()?.resumePosition ?? fallback
              : Duration.zero;
        }
        if (remote == null && !_freshKeys.contains(local!.key)) {
          final ListeningProgress? remotePosition = await _remote.fetchProgress(
            item,
            session,
          );
          await _writes;
          if (!isActive()) return Duration.zero;
          if (readLocal() != local) {
            return readLocal()?.resumePosition ?? fallback;
          }
          if (remotePosition != null &&
              remotePosition.matchesChapter(item) &&
              (remotePosition.positionMs != local.positionMs ||
                  remotePosition.completed != local.completed)) {
            _showConflict(local, remotePosition);
            return remotePosition.resumePosition;
          }
        }
        return local!.resumePosition;
      }
      final ListeningProgress? remote = await _remote.fetchProgress(
        item,
        session,
      );
      await _writes;
      if (!isActive()) return Duration.zero;
      if (readLocal() != local) return readLocal()?.resumePosition ?? fallback;
      if (remote == null || !remote.matchesChapter(item)) {
        return local?.resumePosition ?? fallback;
      }
      final ListeningProgress result = remote.copyWith(
        page: item.page ?? remote.page,
        collectionId: item.collectionId,
      );
      if (await _importProgress(result, local, isCurrent: isActive)) {
        return result.resumePosition;
      }
      return isActive()
          ? readLocal()?.resumePosition ?? fallback
          : Duration.zero;
    } on Object {
      if (!isActive()) return Duration.zero;
      state = state.copyWith(warning: '暂时无法读取B站历史，已使用本地进度');
      return readLocal()?.resumePosition ?? fallback;
    }
  }

  Future<({List<PlayableItem> items, int startIndex})> continuation(
    List<PlayableItem> items,
  ) async {
    final int requestGeneration = ++_resumeGeneration;
    final int sessionGeneration = _sessionGeneration;
    final String account = accountId;
    bool isCurrent() =>
        _isCurrentSession(sessionGeneration, account) &&
        requestGeneration == _resumeGeneration;
    await _capture();
    if (!isCurrent()) throw StateError('收听上下文已切换，请重试');
    final Map<String, ListeningProgress> local = {
      for (final progress in _local.load(account)) progress.key: progress,
    };
    final BiliSession? session = _session;
    List<ListeningProgress> recent = [];
    if (session != null && session.isLoggedIn) {
      try {
        recent = await _remote.fetchRecent(
          session,
          videoIds: {
            for (final item in items)
              item.bvid.isNotEmpty ? 'bvid:${item.bvid}' : 'aid:${item.aid}',
          },
        );
      } on Object {
        if (isCurrent()) state = state.copyWith(warning: '暂时无法读取B站历史，已使用本地进度');
      }
    }
    await _writes;
    if (!isCurrent()) throw StateError('账号或收听上下文已切换，请重试');
    final List<ListeningProgress> current = _local.load(account);
    recent = recent.where((progress) {
      final ListeningProgress? latest = _readProgress(progress);
      return latest == null || latest == local[latest.key];
    }).toList();
    final List<ListeningProgress> candidates = [...recent, ...current]
      ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    for (final ListeningProgress progress in candidates) {
      final int index = items.indexWhere(
        (item) =>
            progress.matchesVideo(item) &&
            ((item.cid ?? 0) > 0
                ? progress.cid == item.cid
                : item.page == null || progress.page == item.page),
      );
      if (index < 0) continue;
      final List<PlayableItem> next = List.of(items);
      next[index] = next[index].copyWith(
        cid: progress.cid,
        page: next[index].page ?? progress.page,
      );
      if (progress.completed && index + 1 < next.length) {
        return (items: next, startIndex: index + 1);
      }
      await _importProgress(
        progress.copyWith(
          collectionId: next[index].collectionId,
          page: next[index].page!,
        ),
        _readProgress(progress),
        isCurrent: isCurrent,
      );
      if (!isCurrent()) throw StateError('收听上下文已切换，请重试');
      return (items: next, startIndex: index);
    }
    return (items: items, startIndex: 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(flush());
    }
  }
}
