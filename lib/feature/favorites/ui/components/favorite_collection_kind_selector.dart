import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteCollectionKindSelector extends ConsumerWidget {
  const FavoriteCollectionKindSelector({super.key, required this.collection});

  final FavoriteCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<CollectionKind>(
      tooltip: '收藏类型',
      initialValue: collection.kind,
      onSelected: (CollectionKind kind) async {
        try {
          await ref
              .read(favoritesControllerProvider.notifier)
              .setCollectionKind(collectionId: collection.id, kind: kind);
        } on Object {
          ToastUtil.show('类型保存失败，请重试');
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<CollectionKind>>[
        for (final CollectionKind kind in CollectionKind.values)
          CheckedPopupMenuItem<CollectionKind>(
            value: kind,
            checked: collection.kind == kind,
            child: Text(kind.label),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              collection.kind == CollectionKind.spoken
                  ? Icons.headphones_rounded
                  : Icons.music_note_rounded,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(collection.kind.label),
            const Icon(Icons.arrow_drop_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
