import 'dart:convert';

import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:hive_ce/hive.dart';

const String listeningProgressBoxName = 'listening_progress';

class ListeningProgressLocalRepository {
  const ListeningProgressLocalRepository(this._box);

  final Box<String> _box;

  List<ListeningProgress> load(String accountId) {
    final List<ListeningProgress> result = [];
    for (final String raw in _box.values) {
      try {
        final Object? value = jsonDecode(raw);
        if (value is! Map<String, dynamic>) continue;
        final ListeningProgress progress = ListeningProgress.fromJson(value);
        if (progress.accountId == accountId && progress.isValid) {
          result.add(progress);
        }
      } on Object {
        continue;
      }
    }
    return result..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
  }

  ListeningProgress? readChapter({
    required String accountId,
    required int aid,
    required String bvid,
    required int cid,
  }) {
    for (final ListeningProgress progress in load(accountId)) {
      if (progress.cid == cid &&
          (bvid.isNotEmpty && progress.bvid.isNotEmpty
              ? progress.bvid == bvid
              : aid > 0 && progress.aid == aid)) {
        return progress;
      }
    }
    return null;
  }

  Future<void> save(ListeningProgress progress) async {
    if (!progress.isValid) throw const FormatException('收听进度无效');
    final List<ListeningProgress> aliases = load(progress.accountId)
        .where(
          (existing) =>
              existing.cid == progress.cid &&
              (progress.bvid.isNotEmpty && existing.bvid.isNotEmpty
                  ? existing.bvid == progress.bvid
                  : progress.aid > 0 && existing.aid == progress.aid),
        )
        .toList();
    final bool conflictingBvids =
        aliases
            .map((p) => p.bvid)
            .where((bvid) => bvid.isNotEmpty)
            .toSet()
            .length >
        1;
    await _box.put(progress.key, jsonEncode(progress.toJson()));
    await _box.deleteAll(<String>[
      for (final ListeningProgress alias in aliases)
        if (alias.key != progress.key &&
            (!conflictingBvids || alias.bvid.isEmpty))
          alias.key,
    ]);
  }

  Future<void> markSynced(ListeningProgress sent) async {
    final ListeningProgress? current = readChapter(
      accountId: sent.accountId,
      aid: sent.aid,
      bvid: sent.bvid,
      cid: sent.cid,
    );
    if (current == sent) await save(sent.copyWith(pendingSync: false));
  }
}
