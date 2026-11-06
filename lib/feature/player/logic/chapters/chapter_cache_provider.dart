import 'dart:async';

import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter_cache_provider.g.dart';

@riverpod
ChapterCacheRepository chapterCacheRepository(Ref ref) =>
    ChapterCacheRepository(Hive.box<String>(chapterCacheBoxName));

@riverpod
bool itemIsCompilation(Ref ref, PlayableItem item) {
  final ChapterCacheRepository cache = ref.watch(
    chapterCacheRepositoryProvider,
  );
  final StreamSubscription<BoxEvent> subscription = cache
      .watch(item.contentId)
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(subscription.cancel);
  return cache.isCompilation(item);
}
