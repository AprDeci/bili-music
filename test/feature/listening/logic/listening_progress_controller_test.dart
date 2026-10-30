import 'dart:async';
import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/listening/data/bili_history_remote_repository.dart';
import 'package:bilimusic/feature/listening/data/listening_progress_local_repository.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const BiliSession _session = BiliSession(
  sessData: 'session-1',
  biliJct: 'csrf-1',
  dedeUserId: '1',
  refreshToken: '',
  cookie: 'SESSDATA=session-1; bili_jct=csrf-1; DedeUserID=1',
);
const PlayableItem _chapter = PlayableItem(
  aid: 1001,
  bvid: 'BVBOOK1',
  cid: 101,
  page: 1,
  title: 'First chapter',
  author: 'Author',
  coverUrl: '',
  kind: CollectionKind.spoken,
  collectionId: 'book',
);
final PlayableItem _nextChapter = _chapter.copyWith(
  cid: 102,
  page: 2,
  title: 'Second chapter',
);
final PlayableItem _otherVideo = _chapter.copyWith(
  aid: 2002,
  bvid: 'BVBOOK2',
  cid: 201,
  title: 'Other book',
);
const Duration _duration = Duration(minutes: 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<String> box;
  late _LocalRepository local;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('listening-logic-test-');
    Hive.init(directory.path);
    box = await Hive.openBox<String>(listeningProgressBoxName);
    local = _LocalRepository(box);
  });

  tearDown(() async {
    await box.close();
    final String resolved = await directory.resolveSymbolicLinks();
    final String tempRoot = await Directory.systemTemp.resolveSymbolicLinks();
    expect(
      resolved,
      startsWith('$tempRoot${Platform.pathSeparator}listening-logic-test-'),
    );
    await directory.delete(recursive: true);
  });

  _Fixture fixture({BiliSession? session = _session}) =>
      _Fixture(local, session: session);

  group('spoken playback events', () {
    test(
      'begin, loading and never-played events do not overwrite progress',
      () async {
        final ListeningProgress existing = _progress(positionMs: 83000);
        await local.save(existing);
        local.reset();
        final _Fixture f = fixture();
        f.begin();

        for (final PlayerEventType type in <PlayerEventType>[
          PlayerEventType.trackChanged,
          PlayerEventType.duration,
          PlayerEventType.position,
          PlayerEventType.playbackState,
          PlayerEventType.stop,
        ]) {
          f.controller.onEvent(_event(type));
        }
        await f.controller.suspend();
        await f.controller.flush();

        expect(local.read(_chapter), existing);
        expect(local.saves, isEmpty);
        expect(f.remote.reports, isEmpty);
      },
    );

    test(
      'only played spoken events capture position through the hub',
      () async {
        final _Fixture f = fixture();
        f.begin(position: const Duration(seconds: 30));
        f.hub.add(
          _event(PlayerEventType.position, positionMs: 0, playing: true),
        );
        await f.settle();
        expect(local.saves, isEmpty);

        f.hub.add(_event(PlayerEventType.playbackState, playing: true));
        f.hub.add(
          _event(PlayerEventType.position, positionMs: 46250, playing: true),
        );
        await f.settle();
        await f.controller.flush();

        final ListeningProgress saved = local.read(_chapter)!;
        expect(saved.positionMs, 46250);
        expect(saved.durationMs, _duration.inMilliseconds);
        expect(saved.cid, 101);
        expect(saved.page, 1);
        expect(saved.collectionId, 'book');
        expect(saved.accountId, '1');
        expect(saved.pendingSync, isFalse);
        expect(saved.completed, isFalse);
        expect(f.remote.reports.single.progress.positionMs, 46250);
        expect(f.remote.reports.single.session, _session);
      },
    );

    test('music events never create or report listening history', () async {
      final _Fixture f = fixture();
      final PlayableItem music = _chapter.copyWith(kind: CollectionKind.music);
      f.begin(item: music);
      for (final PlayerEventType type in PlayerEventType.values) {
        f.controller.onEvent(
          _event(type, item: music, positionMs: 90000, playing: true),
        );
      }
      await f.controller.flush();

      expect(box.values, isEmpty);
      expect(local.saves, isEmpty);
      expect(f.remote.reports, isEmpty);
    });

    test(
      'different chapter, collection, video and null-item events are ignored',
      () async {
        final _Fixture f = fixture();
        f.begin();
        for (final PlayableItem? item in <PlayableItem?>[
          _nextChapter,
          _chapter.copyWith(collectionId: 'other-collection'),
          _otherVideo,
          _chapter.copyWith(kind: CollectionKind.music),
          null,
        ]) {
          f.controller.onEvent(
            _event(PlayerEventType.playbackState, item: item, playing: true),
          );
          f.controller.onEvent(
            _event(PlayerEventType.seek, item: item, positionMs: 90000),
          );
          f.controller.onEvent(_event(PlayerEventType.completed, item: item));
        }
        await f.controller.flush();

        expect(box.values, isEmpty);
        expect(f.remote.reports, isEmpty);
      },
    );

    test(
      'guest playback is local only and duration events update the capture',
      () async {
        final _Fixture f = fixture(session: null);
        f.controller.begin(_chapter, Duration.zero, null);
        f.controller.onEvent(
          _event(
            PlayerEventType.duration,
            duration: const Duration(minutes: 20),
          ),
        );
        f.controller.onEvent(
          _event(PlayerEventType.playbackState, playing: true),
        );
        f.controller.onEvent(
          _event(PlayerEventType.position, positionMs: 27000, playing: true),
        );
        await f.controller.flush();

        final ListeningProgress saved = local.read(
          _chapter,
          accountId: 'guest',
        )!;
        expect(saved.positionMs, 27000);
        expect(saved.durationMs, const Duration(minutes: 20).inMilliseconds);
        expect(saved.pendingSync, isFalse);
        expect(local.read(_chapter), isNull);
        expect(f.remote.reports, isEmpty);
        expect(f.remote.recentRequests, isEmpty);
      },
    );

    test('explicit seek is saved even before playback starts', () async {
      final _Fixture f = fixture();
      f.begin();
      f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 128000));
      await f.controller.flush();

      expect(local.read(_chapter)!.positionMs, 128000);
      expect(f.remote.reports.single.progress.positionMs, 128000);
    });

    test(
      'pause, duplicate positions and lifecycle flushes do not repeatedly write',
      () async {
        final _Fixture f = fixture();
        f.begin();
        f.play(positionMs: 41000);
        await f.controller.flush();
        final ListeningProgress saved = local.read(_chapter)!;
        final int writes = local.saves.length;
        final int reports = f.remote.reports.length;

        for (int i = 0; i < 4; i++) {
          f.controller.onEvent(_event(PlayerEventType.playbackState));
          f.controller.onEvent(
            _event(PlayerEventType.position, positionMs: 41000),
          );
          f.controller.onEvent(_event(PlayerEventType.stop));
          f.controller.didChangeAppLifecycleState(AppLifecycleState.paused);
          await f.controller.flush();
        }

        expect(local.read(_chapter), saved);
        expect(local.saves, hasLength(writes));
        expect(f.remote.reports, hasLength(reports));
      },
    );

    test(
      'suspend snapshots the old chapter before an immediate next begin',
      () async {
        final _Fixture f = fixture(session: null);
        f.begin();
        f.play(positionMs: 11000);
        await f.controller.flush();
        f.controller.onEvent(
          _event(PlayerEventType.position, positionMs: 45000, playing: true),
        );

        final Future<void> suspended = f.controller.suspend();
        f.begin(item: _nextChapter, position: const Duration(seconds: 8));
        await suspended;
        await f.controller.flush();

        expect(local.read(_chapter, accountId: 'guest')!.positionMs, 45000);
        expect(local.read(_nextChapter, accountId: 'guest'), isNull);
        f.play(item: _nextChapter, positionMs: 16000);
        await f.controller.flush();
        expect(local.read(_chapter, accountId: 'guest')!.positionMs, 45000);
        expect(local.read(_nextChapter, accountId: 'guest')!.positionMs, 16000);
      },
    );

    for (final bool pauseBeforeZero in <bool>[false, true]) {
      test(
        'completion survives terminal zero events, pause first: $pauseBeforeZero',
        () async {
          final _Fixture f = fixture(session: null);
          f.begin();
          f.play(positionMs: 590000);
          await f.controller.flush();
          f.controller.onEvent(
            _event(PlayerEventType.completed, positionMs: 600000),
          );
          await f.controller.flush();
          expect(local.read(_chapter, accountId: 'guest')!.completed, isTrue);
          if (pauseBeforeZero) {
            f.controller.onEvent(_event(PlayerEventType.playbackState));
          }
          f.controller.onEvent(_event(PlayerEventType.position));
          f.controller.onEvent(_event(PlayerEventType.playbackState));
          f.controller.onEvent(_event(PlayerEventType.stop));
          await f.controller.flush();

          final ListeningProgress saved = local.read(
            _chapter,
            accountId: 'guest',
          )!;
          expect(saved.completed, isTrue);
          expect(saved.positionMs, _duration.inMilliseconds);
          expect(saved.resumePosition, Duration.zero);
        },
      );
    }

    test(
      'an explicit seek after completion intentionally resumes unfinished progress',
      () async {
        final _Fixture f = fixture(session: null);
        f.begin();
        f.play(positionMs: 590000);
        f.controller.onEvent(_event(PlayerEventType.completed));
        await f.controller.flush();
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 10000));
        await f.controller.flush();

        final ListeningProgress saved = local.read(
          _chapter,
          accountId: 'guest',
        )!;
        expect(saved.completed, isFalse);
        expect(saved.positionMs, 10000);
      },
    );
  });

  group('resume', () {
    test(
      'matching remote CID wins and uses current collection and page',
      () async {
        final ListeningProgress existing = _progress(positionMs: 12000);
        await local.save(existing);
        final _Fixture f = fixture();
        final PlayableItem item = _chapter.copyWith(
          page: 3,
          collectionId: 'current-book',
        );
        f.remote.fetch = (_, _) async => _progress(positionMs: 92000, page: 1);

        expect(
          await f.controller.resumePosition(item),
          const Duration(seconds: 92),
        );
        final ListeningProgress saved = local.read(item)!;
        expect(saved.positionMs, 92000);
        expect(saved.page, 3);
        expect(saved.collectionId, 'current-book');
        expect(saved.pendingSync, isFalse);
        expect(f.remote.progressRequests.single.item, item);
        expect(f.remote.reports, isEmpty);
      },
    );

    for (final bool hasLocal in <bool>[false, true]) {
      test(
        'remote CID mismatch falls back without overwriting, local: $hasLocal',
        () async {
          final ListeningProgress existing = _progress(positionMs: 24000);
          if (hasLocal) await local.save(existing);
          local.reset();
          final _Fixture f = fixture();
          f.remote.fetch = (_, _) async =>
              _progress(item: _nextChapter, positionMs: 155000);

          expect(
            await f.controller.resumePosition(
              _chapter,
              fallback: const Duration(seconds: 7),
            ),
            Duration(seconds: hasLocal ? 24 : 7),
          );
          expect(local.read(_chapter), hasLocal ? existing : isNull);
          expect(local.read(_nextChapter), isNull);
          expect(local.saves, isEmpty);
        },
      );
    }

    test(
      'invalidated resume callback returns zero without importing history',
      () async {
        final ListeningProgress existing = _progress(positionMs: 24000);
        await local.save(existing);
        local.reset();
        final _Fixture f = fixture();
        final Completer<ListeningProgress?> pending =
            Completer<ListeningProgress?>();
        final Completer<void> started = Completer<void>();
        bool current = true;
        f.remote.fetch = (_, _) {
          started.complete();
          return pending.future;
        };
        final Future<Duration> result = f.controller.resumePosition(
          _chapter,
          isCurrent: () => current,
        );
        await started.future;
        current = false;
        pending.complete(_progress(positionMs: 92000));

        expect(await result, Duration.zero);
        expect(local.read(_chapter), existing);
        expect(local.saves, isEmpty);
        expect(f.remote.reports, isEmpty);
        expect(f.state, const ListeningState());
      },
    );

    test(
      'older same-chapter resume cannot overwrite a newer manual seek',
      () async {
        final _Fixture f = fixture();
        final Completer<ListeningProgress?> older =
            Completer<ListeningProgress?>();
        final Completer<ListeningProgress?> newer =
            Completer<ListeningProgress?>();
        final Completer<void> olderStarted = Completer<void>();
        final Completer<void> newerStarted = Completer<void>();
        f.remote.fetch = (_, _) {
          if (f.remote.progressRequests.length == 1) {
            olderStarted.complete();
            return older.future;
          }
          newerStarted.complete();
          return newer.future;
        };
        final Future<Duration> olderResult = f.controller.resumePosition(
          _chapter,
        );
        await olderStarted.future;
        final Future<Duration> newerResult = f.controller.resumePosition(
          _chapter,
        );
        await newerStarted.future;
        newer.complete(_progress(positionMs: 52000));
        expect(await newerResult, const Duration(seconds: 52));
        f.begin(position: const Duration(seconds: 52));
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 73000));
        await f.controller.flush();
        final ListeningProgress manual = local.read(_chapter)!;
        expect(manual.positionMs, 73000);
        local.reset();
        older.complete(_progress(positionMs: 120000));

        expect(await olderResult, Duration.zero);
        expect(local.read(_chapter), manual);
        expect(local.saves, isEmpty);
        expect(f.remote.reports.single.progress.positionMs, 73000);
        expect(f.state, const ListeningState());
      },
    );

    test('a completed matching remote chapter resumes at zero', () async {
      final _Fixture f = fixture();
      f.remote.fetch = (_, _) async =>
          _progress(positionMs: 600000, completed: true);

      expect(await f.controller.resumePosition(_chapter), Duration.zero);
      expect(local.read(_chapter)!.completed, isTrue);
      expect(local.read(_chapter)!.positionMs, 600000);
    });

    for (final int remoteTime in <int>[
      1699999999000,
      1700000000000,
      1700000001000,
    ]) {
      test(
        'pending progress compares real remote timestamp $remoteTime',
        () async {
          final ListeningProgress pending = _progress(
            positionMs: 35000,
            updatedAtMs: 1700000000000,
            pendingSync: true,
          );
          final ListeningProgress remote = _progress(
            positionMs: 81000,
            updatedAtMs: remoteTime,
            collectionId: null,
          );
          await local.save(pending);
          local.reset();
          final _Fixture f = fixture();
          f.remote.recent = (_, _) async => <ListeningProgress>[
            _progress(
              item: _nextChapter,
              positionMs: 999000,
              updatedAtMs: 1800000000000,
            ),
            remote,
          ];
          f.remote.fetch = (_, _) async =>
              throw StateError('timestamped history needs no fallback fetch');

          final bool remoteNewer = remoteTime > pending.updatedAtMs;
          expect(
            await f.controller.resumePosition(_chapter),
            Duration(milliseconds: remoteNewer ? 81000 : 35000),
          );
          expect(
            local.read(_chapter),
            remoteNewer ? remote.copyWith(collectionId: 'book') : pending,
          );
          expect(local.read(_chapter)!.pendingSync, !remoteNewer);
          expect(f.remote.progressRequests, isEmpty);
          expect(f.state.localConflict, isNull);
        },
      );
    }

    for (final bool useLocal in <bool>[false, true]) {
      test(
        'untimestamped conflict is explicit and resolves with local: $useLocal',
        () async {
          final ListeningProgress pending = _progress(
            positionMs: 35000,
            pendingSync: true,
          );
          final ListeningProgress remote = _progress(
            positionMs: 80000,
            updatedAtMs: 0,
          );
          await local.save(pending);
          final _Fixture f = fixture();
          f.remote.fetch = (_, _) async => remote;

          expect(
            await f.controller.resumePosition(_chapter),
            const Duration(seconds: 80),
          );
          expect(local.read(_chapter), pending);
          expect(f.state.localConflict, pending);
          expect(f.state.remoteConflict, remote);
          expect(f.state.warning, isNotEmpty);
          f.begin(position: const Duration(seconds: 80));
          f.play(positionMs: 81000);
          await f.controller.flush();
          expect(local.read(_chapter), pending);
          expect(f.remote.reports, isEmpty);

          final int beforeChoice = DateTime.now().millisecondsSinceEpoch;
          expect(
            await f.controller.resolveConflict(useLocal: useLocal),
            Duration(seconds: useLocal ? 35 : 80),
          );
          await f.controller.flush();
          final ListeningProgress saved = local.read(_chapter)!;
          expect(saved.positionMs, useLocal ? 35000 : 80000);
          expect(saved.pendingSync, isFalse);
          expect(saved.collectionId, 'book');
          expect(saved.page, 1);
          if (useLocal) {
            expect(saved.updatedAtMs, greaterThanOrEqualTo(beforeChoice));
            expect(f.remote.reports.single.progress.positionMs, 35000);
          } else {
            expect(saved.updatedAtMs, 0);
            expect(f.remote.reports, isEmpty);
          }
          expect(f.state.localConflict, isNull);
          expect(f.state.remoteConflict, isNull);
          expect(f.state.warning, isNull);
        },
      );
    }

    test(
      'chapter conflicts stay capture and report blocked until resolved in order',
      () async {
        final ListeningProgress first = _progress(
          positionMs: 35000,
          pendingSync: true,
        );
        final ListeningProgress second = _progress(
          item: _nextChapter,
          positionMs: 45000,
          pendingSync: true,
        );
        final ListeningProgress firstRemote = _progress(
          positionMs: 80000,
          updatedAtMs: 0,
        );
        final ListeningProgress secondRemote = _progress(
          item: _nextChapter,
          positionMs: 90000,
          updatedAtMs: 0,
        );
        await local.save(first);
        await local.save(second);
        local.reset();
        final _Fixture f = fixture();
        f.remote.fetch = (item, _) async =>
            item.cid == _chapter.cid ? firstRemote : secondRemote;

        expect(
          await f.controller.resumePosition(_chapter),
          const Duration(seconds: 80),
        );
        expect(
          await f.controller.resumePosition(_nextChapter),
          const Duration(seconds: 90),
        );
        expect(f.state.localConflict, first);
        expect(f.state.remoteConflict, firstRemote);
        for (final PlayableItem item in <PlayableItem>[
          _chapter,
          _nextChapter,
        ]) {
          f.begin(item: item);
          f.controller.onEvent(
            _event(PlayerEventType.seek, item: item, positionMs: 150000),
          );
          await f.controller.flush();
        }
        expect(local.read(_chapter), first);
        expect(local.read(_nextChapter), second);
        expect(local.saves, isEmpty);
        expect(f.remote.reports, isEmpty);

        expect(
          await f.controller.resolveConflict(
            useLocal: true,
            expectedLocal: first,
            expectedRemote: firstRemote,
          ),
          const Duration(seconds: 35),
        );
        await f.controller.flush();
        expect(local.read(_chapter)!.positionMs, 35000);
        expect(local.read(_chapter)!.pendingSync, isFalse);
        expect(local.read(_nextChapter), second);
        expect(f.remote.reports.single.progress.cid, _chapter.cid);
        expect(f.remote.reports.single.progress.positionMs, 35000);
        expect(f.state.localConflict, second);
        expect(f.state.remoteConflict, secondRemote);
        expect(f.state.warning, isNotEmpty);
        f.controller.onEvent(
          _event(PlayerEventType.seek, item: _nextChapter, positionMs: 160000),
        );
        await f.controller.flush();
        expect(local.read(_nextChapter), second);
        expect(f.remote.reports, hasLength(1));

        expect(
          await f.controller.resolveConflict(
            useLocal: false,
            expectedLocal: second,
            expectedRemote: secondRemote,
          ),
          const Duration(seconds: 90),
        );
        await f.controller.flush();
        expect(local.read(_nextChapter), secondRemote);
        expect(f.remote.reports, hasLength(1));
        expect(f.state, const ListeningState());
      },
    );

    for (final bool oldLocal in <bool>[false, true]) {
      test(
        'old dialog token cannot resolve the next conflict, local: $oldLocal',
        () async {
          final ListeningProgress first = _progress(
            positionMs: 35000,
            pendingSync: true,
          );
          final ListeningProgress firstRemote = _progress(
            positionMs: 80000,
            updatedAtMs: 0,
          );
          final ListeningProgress second = first.copyWith(positionMs: 45000);
          final ListeningProgress secondRemote = firstRemote.copyWith(
            positionMs: 90000,
          );
          await local.save(first);
          final _Fixture f = fixture();
          f.remote.fetch = (_, _) async => firstRemote;
          await f.controller.resumePosition(_chapter);
          await f.controller.resolveConflict(
            useLocal: false,
            expectedLocal: first,
            expectedRemote: firstRemote,
          );
          await local.save(second);
          local.reset();
          f.remote.fetch = (_, _) async => secondRemote;
          await f.controller.resumePosition(_chapter);
          final ListeningState currentState = f.state;
          expect(currentState.localConflict, second);
          expect(currentState.remoteConflict, secondRemote);

          expect(
            await f.controller.resolveConflict(
              useLocal: true,
              expectedLocal: oldLocal ? first : second,
              expectedRemote: oldLocal ? secondRemote : firstRemote,
            ),
            isNull,
          );
          await f.controller.flush();
          expect(local.read(_chapter), second);
          expect(local.saves, isEmpty);
          expect(f.remote.reports, isEmpty);
          expect(f.state, currentState);

          expect(
            await f.controller.resolveConflict(
              useLocal: false,
              expectedLocal: second,
              expectedRemote: secondRemote,
            ),
            const Duration(seconds: 90),
          );
          expect(local.read(_chapter), secondRemote);
          expect(f.state, const ListeningState());
        },
      );
    }

    test('read failure uses local progress and a warning', () async {
      final ListeningProgress existing = _progress(positionMs: 42000);
      await local.save(existing);
      local.reset();
      final _Fixture f = fixture();
      f.remote.fetch = (_, _) async => throw StateError('offline');

      expect(
        await f.controller.resumePosition(_chapter),
        const Duration(seconds: 42),
      );
      expect(local.read(_chapter), existing);
      expect(local.saves, isEmpty);
      expect(f.state.warning, contains('本地'));
    });

    test(
      'pending-history failure retains the actual local position and dirty flag',
      () async {
        final ListeningProgress pending = _progress(
          positionMs: 64000,
          pendingSync: true,
        );
        await local.save(pending);
        final _Fixture f = fixture();
        f.remote.recent = (_, _) async => throw StateError('offline');

        expect(
          await f.controller.resumePosition(_chapter),
          const Duration(seconds: 64),
        );
        expect(local.read(_chapter), pending);
        expect(f.state.warning, isNotEmpty);
        expect(f.remote.reports, isEmpty);
      },
    );

    test(
      'guest resume does not read remote and respects the fallback',
      () async {
        await local.save(_progress(accountId: 'guest', positionMs: 53000));
        await local.save(_progress(positionMs: 99000));
        final _Fixture f = fixture(session: _session.clearAuth());

        expect(
          await f.controller.resumePosition(_chapter),
          const Duration(seconds: 53),
        );
        expect(
          await f.controller.resumePosition(
            _nextChapter,
            fallback: const Duration(seconds: 9),
          ),
          const Duration(seconds: 9),
        );
        expect(f.remote.progressRequests, isEmpty);
        expect(f.remote.recentRequests, isEmpty);
        expect(f.controller.accountId, 'guest');
      },
    );
  });

  group('account isolation', () {
    for (final bool fails in <bool>[false, true]) {
      test(
        'in-flight resume cannot return old account progress, failure: $fails',
        () async {
          await local.save(_progress(positionMs: 45000));
          final _Fixture f = fixture();
          final Completer<ListeningProgress?> pending =
              Completer<ListeningProgress?>();
          final Completer<void> started = Completer<void>();
          f.remote.fetch = (_, _) {
            started.complete();
            return pending.future;
          };
          final Future<Duration> result = f.controller.resumePosition(_chapter);
          await started.future;
          f.session.setValue(_session.copyWith(dedeUserId: '2'));
          await f.settle();
          if (fails) {
            pending.completeError(StateError('old account request failed'));
          } else {
            pending.complete(_progress(positionMs: 120000));
          }

          expect(await result, Duration.zero);
          expect(local.read(_chapter)!.positionMs, 45000);
          expect(local.load('2'), isEmpty);
          expect(f.state.warning, isNull);
          expect(f.state.localConflict, isNull);
        },
      );
    }

    test(
      'pending recent-history resume is discarded after account switch',
      () async {
        final ListeningProgress existing = _progress(
          positionMs: 33000,
          pendingSync: true,
        );
        await local.save(existing);
        final _Fixture f = fixture();
        final Completer<List<ListeningProgress>> pending =
            Completer<List<ListeningProgress>>();
        final Completer<void> started = Completer<void>();
        f.remote.recent = (_, _) {
          started.complete();
          return pending.future;
        };
        final Future<Duration> result = f.controller.resumePosition(_chapter);
        await started.future;
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        pending.complete(<ListeningProgress>[
          _progress(positionMs: 98000, updatedAtMs: 1800000000000),
        ]);

        expect(await result, Duration.zero);
        expect(local.read(_chapter), existing);
        expect(local.load('2'), isEmpty);
        expect(f.state, const ListeningState());
      },
    );

    test(
      'switching account drops old events and flushes only the current account',
      () async {
        final ListeningProgress accountTwo = _progress(
          accountId: '2',
          positionMs: 62000,
          pendingSync: true,
        );
        await local.save(accountTwo);
        final _Fixture f = fixture();
        f.begin();
        f.play(positionMs: 20000);
        await f.controller.flush();
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 99000));
        await f.controller.flush();

        expect(local.read(_chapter)!.positionMs, 20000);
        expect(local.read(_chapter, accountId: '2')!.positionMs, 62000);
        expect(f.remote.reports.map((r) => r.session.dedeUserId), <String>[
          '1',
          '2',
        ]);
        expect(f.remote.reports.map((r) => r.progress.accountId), <String>[
          '1',
          '2',
        ]);
        expect(f.state.localConflict, isNull);
      },
    );

    test(
      'account switch saves the last dirty position only to the old account',
      () async {
        final _Fixture f = fixture();
        f.begin();
        f.play(positionMs: 32000);
        await f.controller.flush();
        f.controller.onEvent(
          _event(PlayerEventType.position, positionMs: 42000, playing: true),
        );
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        await f.controller.flush();

        expect(local.read(_chapter)!.positionMs, 42000);
        expect(local.read(_chapter)!.pendingSync, isTrue);
        expect(local.load('2'), isEmpty);
        expect(f.remote.reports, hasLength(1));
        expect(f.remote.reports.single.progress.positionMs, 32000);
      },
    );

    test(
      'in-flight report failure cannot warn or save into the next account',
      () async {
        final _Fixture f = fixture();
        final Completer<void> pending = Completer<void>();
        final Completer<void> started = Completer<void>();
        f.remote.send = (_, _) {
          started.complete();
          return pending.future;
        };
        f.begin();
        f.play(positionMs: 32000);
        await started.future;
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        pending.completeError(StateError('old account report failed'));
        await f.controller.flush();

        expect(local.read(_chapter)!.pendingSync, isTrue);
        expect(local.read(_chapter)!.positionMs, 32000);
        expect(local.load('2'), isEmpty);
        expect(f.remote.reports.single.session.dedeUserId, '1');
        expect(f.state, const ListeningState());
      },
    );

    test(
      'old report success cannot clear the current account warning',
      () async {
        final _Fixture f = fixture();
        final Completer<void> pending = Completer<void>();
        final Completer<void> started = Completer<void>();
        f.remote.send = (_, _) {
          started.complete();
          return pending.future;
        };
        f.begin();
        f.play(positionMs: 32000);
        await started.future;
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        f.remote.fetch = (_, _) async =>
            throw StateError('new account offline');
        await f.controller.resumePosition(_nextChapter);
        final ListeningState currentState = f.state;
        expect(currentState.warning, isNotEmpty);
        pending.complete();
        await f.controller.flush();

        expect(local.read(_chapter)!.positionMs, 32000);
        expect(local.read(_chapter)!.pendingSync, isFalse);
        expect(local.load('2'), isEmpty);
        expect(f.state, currentState);
      },
    );

    test('old local save failure cannot warn the current account', () async {
      final _Fixture f = fixture();
      final Completer<void> pending = Completer<void>();
      final Completer<void> started = Completer<void>();
      local.beforeSave = (_) {
        started.complete();
        return pending.future;
      };
      f.begin();
      f.play(positionMs: 32000);
      await started.future;
      f.session.setValue(_session.copyWith(dedeUserId: '2'));
      await f.settle();
      pending.completeError(StateError('old account save failed'));
      await f.controller.flush();

      expect(local.load('1'), isEmpty);
      expect(local.load('2'), isEmpty);
      expect(f.remote.reports, isEmpty);
      expect(f.state, const ListeningState());
    });

    test(
      'in-flight conflict lookup cannot resurrect an old account conflict',
      () async {
        final ListeningProgress existing = _progress(
          positionMs: 34000,
          pendingSync: true,
        );
        await local.save(existing);
        final _Fixture f = fixture();
        final Completer<ListeningProgress?> pending =
            Completer<ListeningProgress?>();
        final Completer<void> started = Completer<void>();
        f.remote.fetch = (_, _) {
          started.complete();
          return pending.future;
        };
        final Future<void> flushing = f.controller.flush();
        await started.future;
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        pending.complete(_progress(positionMs: 94000, updatedAtMs: 0));
        await flushing;
        await f.controller.flush();

        expect(local.read(_chapter), existing);
        expect(local.load('2'), isEmpty);
        expect(f.remote.reports, isEmpty);
        expect(f.state, const ListeningState());
      },
    );

    test(
      'switching account invalidates a visible conflict and its resolution',
      () async {
        await local.save(_progress(positionMs: 35000, pendingSync: true));
        final _Fixture f = fixture();
        f.remote.fetch = (_, _) async =>
            _progress(positionMs: 80000, updatedAtMs: 0);
        await f.controller.resumePosition(_chapter);
        expect(f.state.localConflict, isNotNull);
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();

        expect(await f.controller.resolveConflict(useLocal: true), isNull);
        expect(local.load('2'), isEmpty);
        expect(f.state, const ListeningState());
      },
    );
  });

  group('write and report queues', () {
    test('local saves serialize immutable snapshots across chapters', () async {
      final _Fixture f = fixture(session: null);
      final Completer<void> release = Completer<void>();
      final Completer<void> entered = Completer<void>();
      local.beforeSave = (progress) async {
        if (progress.positionMs == 10000) {
          entered.complete();
          await release.future;
        }
      };
      f.begin();
      f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 10000));
      await entered.future;
      f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 20000));
      final Future<void> suspended = f.controller.suspend();
      f.begin(item: _nextChapter);
      f.controller.onEvent(
        _event(PlayerEventType.seek, item: _nextChapter, positionMs: 30000),
      );
      await f.settle();
      final int beforeRelease = local.saves.length;
      release.complete();
      await suspended;
      await f.controller.flush();

      expect(beforeRelease, 1);
      expect(local.maxConcurrentSaves, 1);
      expect(local.saves.map((p) => (p.cid, p.positionMs)), <(int, int)>[
        (101, 10000),
        (101, 20000),
        (102, 30000),
      ]);
      expect(local.read(_chapter, accountId: 'guest')!.positionMs, 20000);
      expect(local.read(_nextChapter, accountId: 'guest')!.positionMs, 30000);
    });

    test(
      'older report acknowledgement cannot mark newer progress synced',
      () async {
        final _Fixture f = fixture();
        final Completer<void> firstReport = Completer<void>();
        final Completer<void> reportStarted = Completer<void>();
        f.remote.send = (_, _) {
          if (f.remote.reports.length == 1) {
            reportStarted.complete();
            return firstReport.future;
          }
          return Future<void>.value();
        };
        f.begin();
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 10000));
        await reportStarted.future;
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 20000));
        await f.controller.resumePosition(_nextChapter);
        final ListeningProgress newer = local.read(_chapter)!;
        expect(newer.positionMs, 20000);
        expect(newer.pendingSync, isTrue);
        firstReport.complete();
        await f.settle();

        expect(local.read(_chapter), newer);
        await f.controller.flush();
        expect(f.remote.reports.map((r) => r.progress.positionMs), <int>[
          10000,
          20000,
        ]);
        expect(f.remote.maxConcurrentReports, 1);
        expect(local.read(_chapter)!.pendingSync, isFalse);
        expect(local.read(_chapter)!.positionMs, 20000);
      },
    );

    test('reports for separate chapters are serialized', () async {
      final _Fixture f = fixture();
      final Completer<void> release = Completer<void>();
      final Completer<void> entered = Completer<void>();
      f.remote.send = (_, _) {
        if (f.remote.reports.length == 1) {
          entered.complete();
          return release.future;
        }
        return Future<void>.value();
      };
      f.begin();
      f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 10000));
      await entered.future;
      await f.controller.suspend();
      f.begin(item: _nextChapter);
      f.controller.onEvent(
        _event(PlayerEventType.seek, item: _nextChapter, positionMs: 20000),
      );
      await f.controller.resumePosition(_otherVideo);
      final int beforeRelease = f.remote.reports.length;
      release.complete();
      await f.controller.flush();

      expect(beforeRelease, 1);
      expect(f.remote.maxConcurrentReports, 1);
      expect(
        f.remote.reports.map((r) => (r.progress.cid, r.progress.positionMs)),
        <(int, int)>[(101, 10000), (102, 20000)],
      );
      expect(local.read(_chapter)!.pendingSync, isFalse);
      expect(local.read(_nextChapter)!.pendingSync, isFalse);
    });

    test(
      'sync failure keeps local data pending and flush retries safely',
      () async {
        final _Fixture f = fixture();
        f.remote.send = (_, _) async => throw StateError('offline');
        f.begin();
        f.play(positionMs: 65000);
        await f.controller.flush();

        expect(local.read(_chapter)!.positionMs, 65000);
        expect(local.read(_chapter)!.pendingSync, isTrue);
        expect(f.state.warning, contains('本地'));
        final int failedAttempts = f.remote.reports.length;
        f.remote.send = (_, _) async {};
        await f.controller.flush();

        expect(f.remote.reports, hasLength(failedAttempts + 1));
        expect(f.remote.reports.last.progress.positionMs, 65000);
        expect(local.read(_chapter)!.pendingSync, isFalse);
        expect(f.state.warning, isNull);
      },
    );

    for (final bool differs in <bool>[false, true]) {
      test(
        'report fallback ignores a changed local snapshot, remote differs: $differs',
        () async {
          final ListeningProgress existing = _progress(
            positionMs: 35000,
            pendingSync: true,
          );
          final ListeningProgress newer = existing.copyWith(
            positionMs: 65000,
            updatedAtMs: 1700000001000,
          );
          await local.save(existing);
          final _Fixture f = fixture();
          final Completer<ListeningProgress?> pending =
              Completer<ListeningProgress?>();
          final Completer<void> started = Completer<void>();
          f.remote.fetch = (_, _) {
            started.complete();
            return pending.future;
          };
          final Future<void> flushing = f.controller.flush();
          await started.future;
          await local.save(newer);
          local.reset();
          pending.complete(
            _progress(positionMs: differs ? 95000 : 35000, updatedAtMs: 0),
          );
          await flushing;

          expect(local.read(_chapter), newer);
          expect(local.saves, isEmpty);
          expect(f.remote.progressRequests.single.item.cid, _chapter.cid);
          expect(f.remote.reports, isEmpty);
          expect(f.state, const ListeningState());
        },
      );
    }

    test(
      'persisted pending sync uses newer timestamped remote without reporting stale data',
      () async {
        final ListeningProgress pending = _progress(
          positionMs: 21000,
          pendingSync: true,
        );
        final ListeningProgress remote = _progress(
          positionMs: 82000,
          updatedAtMs: 1700000001000,
          collectionId: null,
        );
        await local.save(pending);
        final _Fixture f = fixture();
        f.remote.recent = (_, _) async => <ListeningProgress>[remote];
        await f.controller.flush();

        expect(local.read(_chapter), remote.copyWith(collectionId: 'book'));
        expect(f.remote.reports, isEmpty);
        expect(f.remote.progressRequests, isEmpty);
      },
    );

    test(
      'local save failure surfaces a warning and later snapshots still save',
      () async {
        final _Fixture f = fixture(session: null);
        local.beforeSave = (_) async => throw StateError('disk unavailable');
        f.begin();
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 25000));
        await f.controller.flush();
        expect(local.read(_chapter, accountId: 'guest'), isNull);
        expect(f.state.warning, contains('保存失败'));

        local.beforeSave = null;
        f.controller.onEvent(_event(PlayerEventType.seek, positionMs: 26000));
        await f.controller.flush();
        expect(local.read(_chapter, accountId: 'guest')!.positionMs, 26000);
      },
    );
  });

  group('continuation', () {
    for (final bool remoteNewer in <bool>[false, true]) {
      test(
        'selects latest matching remote/local, remote newer: $remoteNewer',
        () async {
          final ListeningProgress localProgress = _progress(
            item: _nextChapter,
            positionMs: 45000,
            updatedAtMs: 1700000002000,
          );
          final ListeningProgress remote = _progress(
            item: _otherVideo,
            positionMs: 87000,
            updatedAtMs: remoteNewer ? 1700000003000 : 1700000001000,
          );
          await local.save(localProgress);
          await local.save(
            _progress(accountId: '2', updatedAtMs: 1900000000000),
          );
          final _Fixture f = fixture();
          f.remote.recent = (_, _) async => <ListeningProgress>[
            _progress(
              item: _chapter.copyWith(cid: 999, page: 9),
              updatedAtMs: 1800000000000,
            ),
            _progress(
              item: _otherVideo.copyWith(aid: 9999, bvid: 'BVNOTINQUEUE'),
              updatedAtMs: 1800000000001,
            ),
            remote,
          ];
          final List<PlayableItem> queue = <PlayableItem>[
            _chapter,
            _nextChapter,
            _otherVideo,
          ];

          final result = await f.controller.continuation(queue);

          expect(result.startIndex, remoteNewer ? 2 : 1);
          expect(result.items.map((p) => p.cid), <int?>[101, 102, 201]);
          expect(queue, <PlayableItem>[_chapter, _nextChapter, _otherVideo]);
          expect(f.remote.recentRequests.single.videoIds, <String>{
            'bvid:BVBOOK1',
            'bvid:BVBOOK2',
          });
          final PlayableItem chosen = result.items[result.startIndex];
          expect(local.read(chosen)!.positionMs, remoteNewer ? 87000 : 45000);
        },
      );
    }

    test(
      'unresolved video takes the remote CID and page without mutating its input',
      () async {
        final PlayableItem unresolved = _chapter.copyWith(
          cid: null,
          page: null,
        );
        final _Fixture f = fixture();
        f.remote.recent = (_, _) async => <ListeningProgress>[
          _progress(
            item: _nextChapter,
            positionMs: 77000,
            updatedAtMs: 1700000001000,
          ),
        ];

        final result = await f.controller.continuation(<PlayableItem>[
          unresolved,
          _otherVideo,
        ]);

        expect(result.startIndex, 0);
        expect(result.items.first.cid, 102);
        expect(result.items.first.page, 2);
        expect(result.items.first.collectionId, 'book');
        expect(unresolved.cid, isNull);
        expect(unresolved.page, isNull);
        expect(local.read(_nextChapter)!.positionMs, 77000);
      },
    );

    test('a known page without CID does not select another chapter', () async {
      final PlayableItem firstPage = _chapter.copyWith(cid: null, page: 1);
      final _Fixture f = fixture();
      f.remote.recent = (_, _) async => <ListeningProgress>[
        _progress(item: _nextChapter, positionMs: 77000),
      ];

      final result = await f.controller.continuation(<PlayableItem>[
        firstPage,
        _otherVideo,
      ]);

      expect(result.startIndex, 0);
      expect(result.items.first, firstPage);
      expect(local.read(_nextChapter), isNull);
    });

    test('completed chapter continues with the next queue entry', () async {
      await local.save(_progress(completed: true, positionMs: 600000));
      final _Fixture f = fixture(session: null);
      await local.save(
        _progress(accountId: 'guest', completed: true, positionMs: 600000),
      );

      final result = await f.controller.continuation(<PlayableItem>[
        _chapter,
        _nextChapter,
      ]);

      expect(result.startIndex, 1);
      expect(result.items, <PlayableItem>[_chapter, _nextChapter]);
      expect(f.remote.recentRequests, isEmpty);
    });

    test('remote continuation failure chooses local with a warning', () async {
      await local.save(_progress(item: _nextChapter, positionMs: 66000));
      final _Fixture f = fixture();
      f.remote.recent = (_, _) async => throw StateError('offline');

      final result = await f.controller.continuation(<PlayableItem>[
        _chapter,
        _nextChapter,
      ]);

      expect(result.startIndex, 1);
      expect(result.items[1].cid, 102);
      expect(result.items[1].page, 2);
      expect(local.read(_nextChapter)!.positionMs, 66000);
      expect(f.state.warning, contains('本地'));
    });

    test(
      'continuation keeps a local snapshot saved while history is pending',
      () async {
        final ListeningProgress existing = _progress(positionMs: 35000);
        final ListeningProgress newer = existing.copyWith(
          positionMs: 65000,
          updatedAtMs: 1700000001000,
          pendingSync: true,
        );
        await local.save(existing);
        final _Fixture f = fixture();
        final Completer<List<ListeningProgress>> pending =
            Completer<List<ListeningProgress>>();
        final Completer<void> started = Completer<void>();
        f.remote.recent = (_, _) {
          started.complete();
          return pending.future;
        };
        final Future<({List<PlayableItem> items, int startIndex})> result = f
            .controller
            .continuation(<PlayableItem>[_chapter, _nextChapter]);
        await started.future;
        await local.save(newer);
        local.reset();
        pending.complete(<ListeningProgress>[
          _progress(positionMs: 95000, updatedAtMs: 1800000000000),
        ]);

        final continuation = await result;
        expect(continuation.startIndex, 0);
        expect(continuation.items, <PlayableItem>[_chapter, _nextChapter]);
        expect(local.read(_chapter), newer);
        expect(local.saves.every((p) => p == newer), isTrue);
        expect(f.remote.reports, isEmpty);
        expect(f.state, const ListeningState());
      },
    );

    test(
      'account switch aborts continuation without importing old history',
      () async {
        final _Fixture f = fixture();
        final Completer<List<ListeningProgress>> pending =
            Completer<List<ListeningProgress>>();
        final Completer<void> started = Completer<void>();
        f.remote.recent = (_, _) {
          started.complete();
          return pending.future;
        };
        final Future<({List<PlayableItem> items, int startIndex})> result = f
            .controller
            .continuation(<PlayableItem>[_chapter, _nextChapter]);
        final Future<void> checked = expectLater(result, throwsStateError);
        await started.future;
        f.session.setValue(_session.copyWith(dedeUserId: '2'));
        await f.settle();
        pending.complete(<ListeningProgress>[
          _progress(item: _nextChapter, positionMs: 88000),
        ]);
        await checked;

        expect(local.load('1'), isEmpty);
        expect(local.load('2'), isEmpty);
        expect(f.state, const ListeningState());
      },
    );

    test('old continuation failure cannot warn the next account', () async {
      final _Fixture f = fixture();
      final Completer<List<ListeningProgress>> pending =
          Completer<List<ListeningProgress>>();
      final Completer<void> started = Completer<void>();
      f.remote.recent = (_, _) {
        started.complete();
        return pending.future;
      };
      final Future<({List<PlayableItem> items, int startIndex})> result = f
          .controller
          .continuation(<PlayableItem>[_chapter, _nextChapter]);
      final Future<void> checked = expectLater(result, throwsStateError);
      await started.future;
      f.session.setValue(_session.copyWith(dedeUserId: '2'));
      await f.settle();
      pending.completeError(StateError('old continuation request failed'));
      await checked;

      expect(local.load('1'), isEmpty);
      expect(local.load('2'), isEmpty);
      expect(f.state, const ListeningState());
    });

    test('no matching history preserves queue and starts from zero', () async {
      await local.save(
        _progress(item: _otherVideo, updatedAtMs: 1900000000000),
      );
      final _Fixture f = fixture();
      final List<PlayableItem> queue = <PlayableItem>[_chapter, _nextChapter];

      final result = await f.controller.continuation(queue);

      expect(result.startIndex, 0);
      expect(result.items, queue);
      expect(f.remote.reports, isEmpty);
    });
  });
}

ListeningProgress _progress({
  PlayableItem item = _chapter,
  String accountId = '1',
  int positionMs = 35000,
  int updatedAtMs = 1700000000000,
  bool pendingSync = false,
  bool completed = false,
  int? page,
  String? collectionId = 'book',
}) => ListeningProgress(
  accountId: accountId,
  aid: item.aid,
  bvid: item.bvid,
  cid: item.cid!,
  page: page ?? item.page ?? 1,
  positionMs: positionMs,
  durationMs: _duration.inMilliseconds,
  updatedAtMs: updatedAtMs,
  pendingSync: pendingSync,
  completed: completed,
  collectionId: collectionId,
);

PlayerEvent _event(
  PlayerEventType type, {
  PlayableItem? item = _chapter,
  int positionMs = 0,
  Duration? duration = _duration,
  bool playing = false,
}) => PlayerEvent(
  type: type,
  item: item,
  position: Duration(milliseconds: positionMs),
  duration: duration,
  isPlaying: playing,
);

class _Fixture {
  _Fixture(this.local, {BiliSession? session = _session})
    : session = _SessionController(session) {
    container = ProviderContainer(
      overrides: [
        biliSessionControllerProvider.overrideWith(() => this.session),
        listeningProgressLocalRepositoryProvider.overrideWithValue(local),
        biliHistoryRemoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);
    container.read(listeningProgressControllerProvider);
  }

  final _LocalRepository local;
  final _SessionController session;
  final _RemoteRepository remote = _RemoteRepository();
  late final ProviderContainer container;

  ListeningState get state =>
      container.read(listeningProgressControllerProvider);
  ListeningProgressController get controller =>
      container.read(listeningProgressControllerProvider.notifier);
  PlayerEventHub get hub => container.read(playerEventHubProvider);

  void begin({
    PlayableItem item = _chapter,
    Duration position = Duration.zero,
  }) => controller.begin(item, position, _duration);

  void play({PlayableItem item = _chapter, required int positionMs}) {
    controller.onEvent(
      _event(PlayerEventType.playbackState, item: item, playing: true),
    );
    controller.onEvent(
      _event(
        PlayerEventType.position,
        item: item,
        positionMs: positionMs,
        playing: true,
      ),
    );
  }

  Future<void> settle() async {
    await container.pump();
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }
}

class _SessionController extends BiliSessionController {
  _SessionController(this.initial);
  final BiliSession? initial;

  @override
  BiliSession? build() => initial;

  void setValue(BiliSession? value) => state = value;
}

class _LocalRepository extends ListeningProgressLocalRepository {
  _LocalRepository(super.box);

  final List<ListeningProgress> saves = <ListeningProgress>[];
  Future<void> Function(ListeningProgress)? beforeSave;
  int concurrentSaves = 0;
  int maxConcurrentSaves = 0;

  void reset() {
    saves.clear();
    maxConcurrentSaves = 0;
  }

  ListeningProgress? read(PlayableItem item, {String accountId = '1'}) =>
      readChapter(
        accountId: accountId,
        aid: item.aid,
        bvid: item.bvid,
        cid: item.cid!,
      );

  @override
  Future<void> save(ListeningProgress progress) async {
    saves.add(progress);
    concurrentSaves++;
    if (concurrentSaves > maxConcurrentSaves) {
      maxConcurrentSaves = concurrentSaves;
    }
    try {
      await beforeSave?.call(progress);
      await super.save(progress);
    } finally {
      concurrentSaves--;
    }
  }
}

class _RemoteRepository implements BiliHistoryRemoteRepository {
  final List<({PlayableItem item, BiliSession session})> progressRequests = [];
  final List<({BiliSession session, Set<String>? videoIds})> recentRequests =
      [];
  final List<({ListeningProgress progress, BiliSession session})> reports = [];
  Future<ListeningProgress?> Function(PlayableItem, BiliSession) fetch =
      (_, _) async => null;
  Future<List<ListeningProgress>> Function(BiliSession, Set<String>?) recent =
      (_, _) async => <ListeningProgress>[];
  Future<void> Function(ListeningProgress, BiliSession) send = (_, _) async {};
  int concurrentReports = 0;
  int maxConcurrentReports = 0;

  @override
  Future<ListeningProgress?> fetchProgress(
    PlayableItem item,
    BiliSession session,
  ) {
    progressRequests.add((item: item, session: session));
    return fetch(item, session);
  }

  @override
  Future<List<ListeningProgress>> fetchRecent(
    BiliSession session, {
    Set<String>? videoIds,
  }) {
    recentRequests.add((session: session, videoIds: videoIds));
    return recent(session, videoIds);
  }

  @override
  Future<void> report(ListeningProgress progress, BiliSession session) async {
    reports.add((progress: progress, session: session));
    concurrentReports++;
    if (concurrentReports > maxConcurrentReports) {
      maxConcurrentReports = concurrentReports;
    }
    try {
      await send(progress, session);
    } finally {
      concurrentReports--;
    }
  }
}
