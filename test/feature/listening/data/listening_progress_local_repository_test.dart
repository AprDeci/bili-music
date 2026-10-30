import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/listening/data/listening_progress_local_repository.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> box;
  late ListeningProgressLocalRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'listening-progress-test-',
    );
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<String>(listeningProgressBoxName);
    repository = ListeningProgressLocalRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    final String resolvedPath = await tempDirectory.resolveSymbolicLinks();
    final String tempRoot = await Directory.systemTemp.resolveSymbolicLinks();
    expect(
      resolvedPath,
      startsWith('$tempRoot${Platform.pathSeparator}listening-progress-test-'),
    );
    await tempDirectory.delete(recursive: true);
  });

  test('save and read isolate accounts, videos and chapters', () async {
    final ListeningProgress first = _progress();
    final ListeningProgress secondChapter = first.copyWith(
      cid: 102,
      page: 2,
      updatedAtMs: 200,
    );
    final ListeningProgress otherAccount = first.copyWith(
      accountId: '2',
      positionMs: 20000,
    );
    final ListeningProgress otherVideo = first.copyWith(
      aid: 1002,
      bvid: 'BVTEST2',
      updatedAtMs: 300,
    );
    for (final ListeningProgress progress in <ListeningProgress>[
      first,
      secondChapter,
      otherAccount,
      otherVideo,
    ]) {
      await repository.save(progress);
    }

    expect(repository.load('1'), <ListeningProgress>[
      otherVideo,
      secondChapter,
      first,
    ]);
    expect(repository.load('2'), <ListeningProgress>[otherAccount]);
    expect(repository.load('missing'), isEmpty);
    expect(
      repository.readChapter(
        accountId: '1',
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 101,
      ),
      first,
    );
    expect(
      repository.readChapter(
        accountId: '1',
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 102,
      ),
      secondChapter,
    );
    expect(
      repository.readChapter(
        accountId: '2',
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 101,
      ),
      otherAccount,
    );
    expect(
      repository.readChapter(
        accountId: '1',
        aid: 1002,
        bvid: 'BVTEST2',
        cid: 101,
      ),
      otherVideo,
    );
    expect(
      repository.readChapter(
        accountId: '1',
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 999,
      ),
      isNull,
    );
    expect(
      repository.readChapter(
        accountId: 'missing',
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 101,
      ),
      isNull,
    );
  });

  test(
    'chapter lookup falls back to aid but does not override a bvid mismatch',
    () async {
      final ListeningProgress progress = _progress();
      await repository.save(progress);

      expect(
        repository.readChapter(accountId: '1', aid: 1001, bvid: '', cid: 101),
        progress,
      );
      expect(
        repository.readChapter(
          accountId: '1',
          aid: 1001,
          bvid: 'BVOTHER',
          cid: 101,
        ),
        isNull,
      );
      expect(
        repository.readChapter(
          accountId: '1',
          aid: 9999,
          bvid: 'BVTEST1',
          cid: 101,
        ),
        progress,
      );

      final ListeningProgress aidOnly = progress.copyWith(
        aid: 1002,
        bvid: '',
        cid: 202,
      );
      await repository.save(aidOnly);

      expect(
        repository.readChapter(
          accountId: '1',
          aid: 1002,
          bvid: 'BVTEST2',
          cid: 202,
        ),
        aidOnly,
      );
    },
  );

  test('save overwrites only the matching account and chapter key', () async {
    final ListeningProgress original = _progress();
    final ListeningProgress sibling = original.copyWith(cid: 102);
    final ListeningProgress updated = original.copyWith(
      positionMs: 60000,
      updatedAtMs: 200,
    );
    await repository.save(original);
    await repository.save(sibling);
    await repository.save(updated);

    expect(box.length, 2);
    expect(repository.load('1'), <ListeningProgress>[updated, sibling]);
  });

  for (final bool saveBvid in <bool>[true, false]) {
    test(
      'save coalesces ${saveBvid ? 'aid-only to bvid' : 'bvid to aid-only'} aliases',
      () async {
        final ListeningProgress obsolete = _progress().copyWith(
          bvid: saveBvid ? '' : 'BVTEST1',
          updatedAtMs: 300,
        );
        final ListeningProgress chosen = _progress().copyWith(
          bvid: saveBvid ? 'BVTEST1' : '',
          page: 3,
          positionMs: 60000,
          updatedAtMs: 200,
          completed: true,
          pendingSync: false,
          collectionId: 'chosen-collection',
        );
        await repository.save(obsolete);
        await repository.save(chosen);
        await box.close();
        box = await Hive.openBox<String>(listeningProgressBoxName);
        repository = ListeningProgressLocalRepository(box);

        expect(box.keys, <String>[chosen.key]);
        expect(box.get(obsolete.key), isNull);
        expect(jsonDecode(box.get(chosen.key)!), chosen.toJson());
        expect(repository.load('1'), <ListeningProgress>[chosen]);
        expect(repository.load('1').where((p) => p.pendingSync), isEmpty);
        for (final String bvid in <String>['', 'BVTEST1']) {
          expect(
            repository.readChapter(
              accountId: '1',
              aid: 1001,
              bvid: bvid,
              cid: 101,
            ),
            chosen,
          );
        }

        final ListeningProgress remote = chosen.copyWith(
          positionMs: 15000,
          updatedAtMs: 0,
          completed: false,
        );
        await repository.save(remote);
        await repository.markSynced(obsolete);

        expect(repository.load('1'), <ListeningProgress>[remote]);
        expect(repository.load('1').where((p) => p.pendingSync), isEmpty);
        expect(
          repository.readChapter(
            accountId: '1',
            aid: 1001,
            bvid: 'BVTEST1',
            cid: 101,
          ),
          remote,
        );
      },
    );
  }

  test('save keeps the chosen alias pending until it is synced', () async {
    final ListeningProgress obsolete = _progress().copyWith(
      bvid: '',
      pendingSync: false,
    );
    final ListeningProgress chosen = _progress().copyWith(updatedAtMs: 200);
    await repository.save(obsolete);
    await repository.save(chosen);

    expect(repository.load('1'), <ListeningProgress>[chosen]);
    await repository.markSynced(obsolete);
    expect(repository.load('1'), <ListeningProgress>[chosen]);

    await repository.markSynced(chosen);

    expect(box.keys, <String>[chosen.key]);
    expect(repository.load('1'), <ListeningProgress>[
      chosen.copyWith(pendingSync: false),
    ]);
  });

  test('save coalesces aliases without removing isolated records', () async {
    final ListeningProgress obsolete = _progress().copyWith(bvid: '');
    final ListeningProgress chosen = _progress().copyWith(updatedAtMs: 200);
    final ListeningProgress otherAccount = obsolete.copyWith(accountId: '2');
    final ListeningProgress otherChapter = obsolete.copyWith(cid: 102);
    final ListeningProgress otherVideo = obsolete.copyWith(aid: 1002);
    final ListeningProgress conflictingBvid = _progress().copyWith(
      bvid: 'BVOTHER',
    );
    for (final ListeningProgress progress in <ListeningProgress>[
      obsolete,
      otherAccount,
      otherChapter,
      otherVideo,
      conflictingBvid,
    ]) {
      await box.put(progress.key, jsonEncode(progress.toJson()));
    }

    await repository.save(chosen);

    expect(box.get(obsolete.key), isNull);
    expect(box.length, 5);
    expect(
      repository.load('1'),
      unorderedEquals(<ListeningProgress>[
        chosen,
        otherChapter,
        otherVideo,
        conflictingBvid,
      ]),
    );
    expect(repository.load('2'), <ListeningProgress>[otherAccount]);
    expect(
      repository.readChapter(
        accountId: '1',
        aid: 1001,
        bvid: 'BVOTHER',
        cid: 101,
      ),
      conflictingBvid,
    );
  });

  test('save does not merge conflicting nonempty bvids', () async {
    final ListeningProgress first = _progress();
    final ListeningProgress other = first.copyWith(
      bvid: 'BVOTHER',
      positionMs: 15000,
      updatedAtMs: 200,
      pendingSync: false,
    );
    await repository.save(first);
    await repository.save(other);

    expect(box.length, 2);
    expect(repository.load('1'), <ListeningProgress>[other, first]);
    for (final ListeningProgress progress in <ListeningProgress>[
      first,
      other,
    ]) {
      expect(
        repository.readChapter(
          accountId: progress.accountId,
          aid: progress.aid,
          bvid: progress.bvid,
          cid: progress.cid,
        ),
        progress,
      );
    }
  });

  test('aid-only save does not bridge conflicting nonempty bvids', () async {
    final ListeningProgress first = _progress();
    final ListeningProgress other = first.copyWith(bvid: 'BVOTHER');
    final ListeningProgress aidOnly = first.copyWith(
      bvid: '',
      updatedAtMs: 0,
      pendingSync: false,
    );
    await repository.save(first);
    await repository.save(other);

    await repository.save(aidOnly);

    expect(box.length, 3);
    expect(
      repository.load('1'),
      unorderedEquals(<ListeningProgress>[first, other, aidOnly]),
    );
  });

  test('save preserves an obsolete alias when the new write fails', () async {
    final ListeningProgress obsolete = _progress().copyWith(bvid: '');
    final ListeningProgress chosen = _progress().copyWith(pendingSync: false);
    await repository.save(obsolete);
    final _FailingWriteBox failingBox = _FailingWriteBox(box);
    final ListeningProgressLocalRepository failingRepository =
        ListeningProgressLocalRepository(failingBox);

    await expectLater(failingRepository.save(chosen), throwsStateError);

    expect(failingBox.deletedKeys, isEmpty);
    expect(box.keys, <String>[obsolete.key]);
    expect(repository.load('1'), <ListeningProgress>[obsolete]);
  });

  test(
    'all progress fields survive closing and reopening the String box',
    () async {
      final ListeningProgress progress = _progress().copyWith(
        page: 3,
        completed: true,
        collectionId: 'spoken-collection',
      );
      await repository.save(progress);
      await box.close();
      box = await Hive.openBox<String>(listeningProgressBoxName);
      repository = ListeningProgressLocalRepository(box);

      expect(repository.load('1'), <ListeningProgress>[progress]);
      expect(jsonDecode(box.get(progress.key)!), progress.toJson());
    },
  );

  test(
    'markSynced clears the exact sent version without changing its fields',
    () async {
      final ListeningProgress sent = _progress();
      await repository.save(sent);

      await repository.markSynced(sent);

      expect(repository.load('1'), <ListeningProgress>[
        sent.copyWith(pendingSync: false),
      ]);
    },
  );

  test('markSynced does not clear a newer pending chapter version', () async {
    final ListeningProgress sent = _progress();
    final ListeningProgress newer = sent.copyWith(
      positionMs: 50000,
      updatedAtMs: 200,
    );
    await repository.save(sent);
    await repository.save(newer);

    await repository.markSynced(sent);

    expect(repository.load('1'), <ListeningProgress>[newer]);
    expect(repository.load('1').single.pendingSync, isTrue);
  });

  test(
    'markSynced compares the whole snapshot, not just its timestamp',
    () async {
      final ListeningProgress sent = _progress();
      final ListeningProgress newer = sent.copyWith(positionMs: 50000);
      await repository.save(newer);

      await repository.markSynced(sent);

      expect(repository.load('1'), <ListeningProgress>[newer]);
      expect(newer.updatedAtMs, sent.updatedAtMs);
    },
  );

  test('markSynced does not create a missing record', () async {
    await repository.markSynced(_progress());

    expect(box.isEmpty, isTrue);
  });

  test(
    'load skips malformed and invalid values without losing valid records',
    () async {
      final ListeningProgress valid = _progress();
      await repository.save(valid);
      final List<String> malformed = <String>[
        '',
        '{',
        'null',
        '[]',
        '"not a record"',
        '{}',
        jsonEncode(<String, dynamic>{
          ...valid.toJson(),
          'positionMs': 'invalid',
        }),
        jsonEncode(<String, dynamic>{
          ...valid.toJson(),
          'pendingSync': 'invalid',
        }),
        jsonEncode(valid.copyWith(accountId: '').toJson()),
        jsonEncode(valid.copyWith(aid: 0, bvid: '').toJson()),
        jsonEncode(valid.copyWith(aid: -1).toJson()),
        jsonEncode(valid.copyWith(cid: 0).toJson()),
        jsonEncode(valid.copyWith(positionMs: -1).toJson()),
        jsonEncode(valid.copyWith(durationMs: -1).toJson()),
        jsonEncode(valid.copyWith(updatedAtMs: -1).toJson()),
      ];
      for (int index = 0; index < malformed.length; index++) {
        await box.put('malformed-$index', malformed[index]);
      }

      expect(repository.load('1'), <ListeningProgress>[valid]);
      expect(
        repository.readChapter(
          accountId: '1',
          aid: 1001,
          bvid: 'BVTEST1',
          cid: 101,
        ),
        valid,
      );
      expect(box.length, malformed.length + 1);
    },
  );

  final Map<String, ListeningProgress> invalidProgress =
      <String, ListeningProgress>{
        'empty account': _progress().copyWith(accountId: ''),
        'missing video identity': _progress().copyWith(aid: 0, bvid: ''),
        'negative aid without bvid': _progress().copyWith(aid: -1, bvid: ''),
        'negative aid with bvid': _progress().copyWith(aid: -1),
        'zero cid': _progress().copyWith(cid: 0),
        'negative cid': _progress().copyWith(cid: -1),
        'zero page': _progress().copyWith(page: 0),
        'negative page': _progress().copyWith(page: -1),
        'negative position': _progress().copyWith(positionMs: -1),
        'negative duration': _progress().copyWith(durationMs: -1),
        'negative timestamp': _progress().copyWith(updatedAtMs: -1),
      };
  for (final MapEntry<String, ListeningProgress> entry
      in invalidProgress.entries) {
    test('domain and save reject ${entry.key}', () async {
      expect(entry.value.isValid, isFalse);
      await expectLater(repository.save(entry.value), throwsFormatException);
      expect(box.isEmpty, isTrue);
    });
  }

  test(
    'domain JSON, video keys and resume positions preserve chapter semantics',
    () {
      final ListeningProgress progress = _progress();
      const PlayableItem item = PlayableItem(
        aid: 1001,
        bvid: 'BVTEST1',
        cid: 101,
        title: '',
        author: '',
        coverUrl: '',
      );

      expect(ListeningProgress.fromJson(progress.toJson()), progress);
      expect(progress.videoId, 'bvid:BVTEST1');
      expect(progress.key, '1:bvid:BVTEST1:cid:101');
      expect(progress.copyWith(accountId: '2').key, isNot(progress.key));
      expect(progress.copyWith(cid: 102).key, isNot(progress.key));
      expect(progress.copyWith(bvid: '').videoId, 'aid:1001');
      expect(progress.copyWith(aid: 0).isValid, isTrue);
      expect(progress.copyWith(bvid: '').isValid, isTrue);
      expect(progress.matchesChapter(item), isTrue);
      expect(progress.matchesChapter(item.copyWith(cid: 102)), isFalse);
      expect(progress.matchesVideo(item.copyWith(cid: 102)), isTrue);
      expect(progress.matchesVideo(item.copyWith(bvid: 'BVOTHER')), isFalse);
      expect(progress.matchesVideo(item.copyWith(bvid: '')), isTrue);
      expect(progress.resumePosition, const Duration(milliseconds: 42000));
      expect(progress.copyWith(completed: true).resumePosition, Duration.zero);
    },
  );
}

class _FailingWriteBox implements Box<String> {
  _FailingWriteBox(this._box);

  final Box<String> _box;
  final List<dynamic> deletedKeys = <dynamic>[];

  @override
  Iterable<String> get values => _box.values;

  @override
  Future<void> put(dynamic key, String value) async {
    throw StateError('write failed');
  }

  @override
  Future<void> delete(dynamic key) async {
    deletedKeys.add(key);
    await _box.delete(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    deletedKeys.addAll(keys);
    await _box.deleteAll(keys);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ListeningProgress _progress() => const ListeningProgress(
  accountId: '1',
  aid: 1001,
  bvid: 'BVTEST1',
  cid: 101,
  positionMs: 42000,
  durationMs: 120000,
  updatedAtMs: 100,
  pendingSync: true,
  collectionId: 'collection',
);
