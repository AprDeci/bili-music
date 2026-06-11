import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UpCollectionList extends ConsumerWidget {
  const UpCollectionList({
    super.key,
    required this.mid,
    required this.ownerName,
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    this.loadMoreError,
  });

  final int mid;
  final String ownerName;
  final List<UpCollection> items;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? loadMoreError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty && error != null) {
      return Center(
        child: TextButton(
          onPressed: () => ref.invalidate(upPageControllerProvider(mid)),
          child: Text(error!),
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(child: Text('暂无合集'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.extentAfter < 320 && hasMore) {
          ref
              .read(upPageControllerProvider(mid).notifier)
              .loadMoreCollections();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (loadMoreError != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: TextButton(
                    onPressed: () => ref
                        .read(upPageControllerProvider(mid).notifier)
                        .loadMoreCollections(),
                    child: Text(loadMoreError!),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(hasMore ? '继续滚动加载' : '没有更多了')),
            );
          }
          final UpCollection item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CommonCachedImage(
              imageUrl: item.coverUrl,
              width: 88,
              height: 56,
              borderRadius: BorderRadius.circular(10),
              fallbackIcon: Icons.queue_music_rounded,
            ),
            title: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('共 ${item.total} 个视频'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(
              '/up/$mid/collection/${item.seasonId}',
              extra: ownerName,
            ),
          );
        },
      ),
    );
  }
}
