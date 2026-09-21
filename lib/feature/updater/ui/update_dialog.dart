import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:flutter/material.dart';

enum UpdateDialogAction { later, openReleasePage, downloadAndInstall }

/// 发现新版本时的弹窗；返回用户选择的动作，点击遮罩关闭时返回 null。
Future<UpdateDialogAction?> showUpdateDialog(
  BuildContext context, {
  required String currentVersion,
  required String latestVersion,
  required UpdateRelease release,
  required UpdateAsset? installAsset,
}) {
  final ThemeData theme = Theme.of(context);
  final String title = release.title.isEmpty
      ? '发现新版本 ${release.tagName}'
      : release.title;
  final String body = release.body.isEmpty ? '暂无更新说明' : release.body;

  return showDialog<UpdateDialogAction>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前版本 $currentVersion → $latestVersion',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text('更新内容', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SelectableText(body),
                if (installAsset != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    '安装包：${installAsset.name}'
                    '（${formatBytes(installAsset.sizeBytes)}）',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(UpdateDialogAction.later),
            child: const Text('稍后'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              installAsset == null
                  ? UpdateDialogAction.openReleasePage
                  : UpdateDialogAction.downloadAndInstall,
            ),
            child: Text(installAsset == null ? '前往更新' : '下载更新'),
          ),
        ],
      );
    },
  );
}
