import 'dart:io';

import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Box<Map> box;
  late StatisticsLocalRepository repository;

  setUpAll(() {
    Hive.init(Directory.systemTemp.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map>('statistics_repository_test');
    await box.clear();
    repository = StatisticsLocalRepository(box);
  });

  tearDown(() => box.close());

  SongStatistics statistics(String stableId) =>
      SongStatistics(stableId: stableId, title: stableId, playCount: 1);

  test('falls back to the only cid record', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));

    expect(repository.readCompatible('bvid:BV1')?.stableId, 'bvid:BV1:cid:123');
  });

  test('does not guess between multiple cid records', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));
    await repository.write(statistics('bvid:BV1:cid:456'));

    expect(repository.readCompatible('bvid:BV1'), isNull);
  });

  test('exact cid lookup takes precedence', () async {
    await repository.write(statistics('bvid:BV1:cid:123'));
    await repository.write(statistics('bvid:BV1:cid:456'));

    expect(
      repository.readCompatible('bvid:BV1:cid:456')?.stableId,
      'bvid:BV1:cid:456',
    );
  });
}
