import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorited_season_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<FavoritedSeason> box;
  late FavoritedSeasonLocalRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'favorited-season-test-',
    );
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(FavoritedSeasonAdapter());
    }
    box = await Hive.openBox<FavoritedSeason>(favoritedSeasonsBoxName);
    repository = FavoritedSeasonLocalRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(favoritedSeasonsBoxName);
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('save replaces a season snapshot and retains its unique key', () async {
    await repository.save(
      _season(seasonId: 1, title: 'before', favoritedAt: 1),
    );

    final List<FavoritedSeason> result = await repository.save(
      _season(seasonId: 1, title: 'after', favoritedAt: 1),
    );

    expect(result, hasLength(1));
    expect(result.single.title, 'after');
    expect(result.single.seasonId, 1);
  });

  test('load sorts by newest favorite and delete removes the season', () async {
    await repository.save(_season(seasonId: 1, title: 'older', favoritedAt: 1));
    await repository.save(_season(seasonId: 2, title: 'newer', favoritedAt: 2));

    expect(repository.load().map((FavoritedSeason item) => item.seasonId), [
      2,
      1,
    ]);

    final List<FavoritedSeason> result = await repository.delete(2);

    expect(result.map((FavoritedSeason item) => item.seasonId), [1]);
  });
}

FavoritedSeason _season({
  required int seasonId,
  required String title,
  required int favoritedAt,
}) {
  return FavoritedSeason(
    seasonId: seasonId,
    mid: 100,
    title: title,
    coverUrl: 'https://example.com/$seasonId.jpg',
    total: 10,
    favoritedAtEpochMs: favoritedAt,
    updatedAtEpochMs: favoritedAt,
    lastSyncedAtEpochMs: favoritedAt,
  );
}
