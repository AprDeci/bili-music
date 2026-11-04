import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> requestTrackDownload(WidgetRef ref, PlayableItem item) async {
  final DownloadState state = ref.read(downloadControllerProvider);
  if (state.contains(item.contentId)) {
    ToastUtil.show('已经下载过了');
    return;
  }
  if (state.taskFor(item.contentId)?.isActive ?? false) {
    ToastUtil.show('正在下载中');
    return;
  }
  final bool queued = await ref
      .read(downloadControllerProvider.notifier)
      .download(item);
  ToastUtil.show(queued ? '已加入下载队列' : '下载未开始');
}
