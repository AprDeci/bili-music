import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadQueuePage extends ConsumerWidget {
  const DownloadQueuePage({super.key});

  Future<void> _cancel(WidgetRef ref, String contentId) async {
    try {
      await ref.read(downloadControllerProvider.notifier).cancel(contentId);
    } on Object {
      ToastUtil.show('取消下载失败，请重试');
    }
  }

  Future<void> _retry(WidgetRef ref, String contentId) async {
    try {
      final bool queued = await ref
          .read(downloadControllerProvider.notifier)
          .retry(contentId);
      ToastUtil.show(queued ? '已加入下载队列' : '已下载或正在下载');
    } on Object {
      ToastUtil.show('重试下载失败，请重试');
    }
  }

  Future<void> _retryFailed(WidgetRef ref) async {
    try {
      final int count = await ref
          .read(downloadControllerProvider.notifier)
          .retryFailed();
      ToastUtil.show(count > 0 ? '已加入 $count 首歌曲到下载队列' : '没有可重试的下载');
    } on Object {
      ToastUtil.show('重试下载失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    final List<DownloadTask> tasks = state.tasks.values.toList(growable: false);
    final bool hasFailed = tasks.any(
      (DownloadTask task) => task.status == DownloadTaskStatus.failed,
    );
    final bool desktop = AppLayoutScope.of(context) == AppLayout.desktop;
    final Widget retryAll = TextButton(
      onPressed: () => _retryFailed(ref),
      child: const Text('重试失败项'),
    );

    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              title: const Text('正在下载'),
              actions: <Widget>[if (hasFailed) retryAll],
            ),
      body: Column(
        children: <Widget>[
          if (desktop)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 14, 4),
              child: Row(
                children: <Widget>[
                  const BackButton(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '正在下载',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (hasFailed) retryAll,
                ],
              ),
            ),
          Expanded(
            child: tasks.isEmpty
                ? StatusView(
                    icon: state.errorMessage == null
                        ? Icons.download_done_rounded
                        : Icons.error_outline_rounded,
                    title: state.errorMessage ?? '暂无下载任务',
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: tasks.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == tasks.length) {
                        return const BottomPageSpacer();
                      }
                      final DownloadTask task = tasks[index];
                      return _DownloadTaskTile(
                        task: task,
                        onCancel: () => _cancel(ref, task.contentId),
                        onRetry: () => _retry(ref, task.contentId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DownloadTaskTile extends StatelessWidget {
  const _DownloadTaskTile({
    required this.task,
    required this.onCancel,
    required this.onRetry,
  });

  final DownloadTask task;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool failed = task.status == DownloadTaskStatus.failed;
    final double? progress = task.progress;
    final String partTitle = task.item.pageTitle?.trim() ?? '';
    final String title = <String>[
      task.item.title.isEmpty ? '未命名歌曲' : task.item.title,
      if ((task.item.page ?? 1) > 1 || partTitle.isNotEmpty)
        'P${task.item.page ?? 1}${partTitle.isEmpty ? '' : ' $partTitle'}',
    ].join(' · ');
    final String status = switch (task.status) {
      DownloadTaskStatus.queued => '等待下载',
      DownloadTaskStatus.running =>
        progress == null
            ? '下载中'
            : '下载中 ${(progress * 100).toStringAsFixed(0)}%',
      DownloadTaskStatus.failed => '下载失败',
    };
    final String bytes = task.totalBytes > 0
        ? '${formatBytes(task.receivedBytes)} / ${formatBytes(task.totalBytes)}'
        : formatBytes(task.receivedBytes);

    return ListTile(
      key: ValueKey<String>(task.contentId),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: CommonCachedImage(
        imageUrl: task.item.coverUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
        fallbackIcon: Icons.music_note_rounded,
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(task.item.author, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('$status · $bytes', style: theme.textTheme.bodySmall),
          if (failed && (task.errorMessage?.isNotEmpty ?? false))
            Text(
              task.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          if (task.status == DownloadTaskStatus.running)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                semanticsLabel: '${task.item.title}下载进度',
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (failed)
            IconButton(
              tooltip: '重试下载',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ),
          IconButton(
            tooltip: '取消下载',
            icon: const Icon(Icons.close_rounded),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
