import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_backfill_controller.g.dart';

// 串行补齐元信息：加入收藏时自动入队，或手动“补齐/检测”时批量入队。
@Riverpod(keepAlive: true)
class MetadataBackfillController extends _$MetadataBackfillController {
  static final AppLogger _logger = AppLogger('MetadataBackfill');

  final List<PlayableItem> _pending = <PlayableItem>[];
  final Set<String> _pendingContentIds = <String>{};
  bool _isDraining = false;
  bool _cancelRequested = false;
  int _processed = 0;
  int _total = 0;
  int _matched = 0;

  @override
  MetadataBackfillState build() => const MetadataBackfillState();

  // 加入收藏后入队；命中缓存的行会在 _drain 里被跳过。
  void enqueue(PlayableItem item) {
    if (item.isSpoken ||
        !item.hasIdentity ||
        !_pendingContentIds.add(item.contentId)) {
      return;
    }
    _pending.add(item);
    _total++;
    _publish();
    unawaited(_drain());
  }

  // 每次点击都重扫集合：已匹配的跳过，未匹配的入队续扫。
  // 返回本次新入队的数量（0 表示没有需要补齐的）。
  Future<int> backfillMissing(Iterable<PlayableItem> items) async {
    final bool alreadyDraining = _isDraining;
    if (!alreadyDraining) {
      _processed = 0;
      _matched = 0;
      _cancelRequested = false;
    }

    int queued = 0;
    for (final PlayableItem item in items) {
      if (item.isSpoken ||
          !item.hasIdentity ||
          _pendingContentIds.contains(item.contentId)) {
        continue;
      }
      final Metadata? cached = await ref
          .read(metadataCacheRepositoryProvider)
          .getCachedMetadataByContentId(item.contentId);
      if (cached?.hasContent ?? false) {
        continue;
      }
      _pendingContentIds.add(item.contentId);
      _pending.add(item);
      queued++;
    }

    _total = _processed + _pending.length;
    _publish();
    unawaited(_drain());
    return queued;
  }

  void cancel() {
    if (_isDraining) {
      _cancelRequested = true;
    }
  }

  Future<void> _drain() async {
    if (_isDraining || _pending.isEmpty) {
      return;
    }
    _isDraining = true;
    _cancelRequested = false;
    _publish();

    try {
      while (_pending.isNotEmpty && !_cancelRequested) {
        final PlayableItem item = _pending.removeAt(0);
        if (item.isSpoken) {
          _pendingContentIds.remove(item.contentId);
          _processed++;
          _publish();
          continue;
        }

        try {
          final MetadataLookupService lookup = ref.read(
            metadataLookupServiceProvider,
          );
          final MetadataCacheRepository repository = ref.read(
            metadataCacheRepositoryProvider,
          );
          final Metadata? cached = await repository
              .getCachedMetadataByContentId(item.contentId);
          if (!(cached?.hasContent ?? false)) {
            final MetadataLookupResult result = await lookup.lookup(
              item: item,
              title: _lookupTitle(item),
            );
            await repository.putCachedMetadata(
              item: item,
              metadata: result.metadata,
            );
            if (result.metadata.hasContent) {
              _matched++;
            }
            ref.invalidate(favoriteEntryMetadataProvider(item.contentId));
          }
        } on Object catch (error) {
          _logger.d('backfill failed for ${item.contentId}: $error');
        }

        _pendingContentIds.remove(item.contentId);
        _processed++;
        _publish();
        if (_pending.isNotEmpty && !_cancelRequested) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
    } finally {
      // 丢弃未处理项并释放去重标记，保证下次点击能续扫。
      for (final PlayableItem item in _pending) {
        _pendingContentIds.remove(item.contentId);
      }
      _pending.clear();
      _isDraining = false;
      _publish();
    }
  }

  String _lookupTitle(PlayableItem item) {
    final String pageTitle = item.pageTitle?.trim() ?? '';
    return pageTitle.isNotEmpty ? pageTitle : item.title.trim();
  }

  void _publish() {
    state = MetadataBackfillState(
      isRunning: _isDraining,
      processed: _processed,
      total: _total,
      matched: _matched,
    );
  }
}
