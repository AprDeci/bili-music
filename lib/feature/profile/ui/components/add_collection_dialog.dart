import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAddCollectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required bool remote,
}) async {
  if (remote &&
      !(ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false)) {
    LoginPrompt.show(context, reason: '网络歌单需要登录 B 站账号');
    return;
  }

  bool importExisting = false;
  if (remote) {
    final bool? action = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('添加网络歌单'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(true),
            child: const ListTile(
              leading: Icon(Icons.cloud_download_outlined),
              title: Text('导入已有收藏夹'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(false),
            child: const ListTile(
              leading: Icon(Icons.add_rounded),
              title: Text('新建网络歌单'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
    if (!context.mounted || action == null) return;
    importExisting = action;
  }

  final FavoritesController controller = ref.read(
    favoritesControllerProvider.notifier,
  );
  try {
    if (importExisting) {
      final FavoriteCollection? collection =
          await showDialog<FavoriteCollection>(
            context: context,
            useRootNavigator: true,
            builder: (context) => RemoteCollectionImportDialog(
              collectionsFuture: controller.fetchImportableRemoteCollections(),
            ),
          );
      if (!context.mounted || collection == null) return;
      final CollectionKind? kind = await showCollectionKindDialog(
        context: context,
        initialKind: collection.kind,
      );
      if (!context.mounted || kind == null) return;
      await controller.bindRemoteCollection(collection.copyWith(kind: kind));
      await controller.refreshRemoteCollectionItems(
        collectionId: collection.id,
      );
      if (context.mounted) ToastUtil.show('已导入“${collection.name}”');
      return;
    }

    final String? name = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => CollectionNameDialog(
        title: remote ? '新建网络歌单' : '新建歌单',
        hintText: '例如：深夜循环',
        confirmText: '创建',
      ),
    );
    if (!context.mounted || name == null) return;
    if (name.trim().isEmpty) {
      ToastUtil.show('歌单名称不能为空');
      return;
    }
    final CollectionKind? kind = await showCollectionKindDialog(
      context: context,
    );
    if (!context.mounted || kind == null) return;
    final FavoriteCollection? collection = remote
        ? await controller.createRemoteCollection(name, kind: kind)
        : await controller.createCollection(name, kind: kind);
    if (context.mounted && collection == null) {
      ToastUtil.show(remote ? '创建网络歌单失败' : '歌单名称已存在');
    }
  } on Object catch (error) {
    if (!context.mounted) return;
    if (!LoginPrompt.handle(context, error, reason: '网络歌单需要登录 B 站账号')) {
      ToastUtil.show('添加歌单失败，请稍后重试');
    }
  }
}

class CollectionNameDialog extends StatefulWidget {
  const CollectionNameDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
  });

  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

  @override
  State<CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 24,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (String value) => Navigator.of(context).pop(value),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
