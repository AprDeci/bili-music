import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeningProgressListener extends ConsumerStatefulWidget {
  const ListeningProgressListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<ListeningProgressListener> createState() =>
      _ListeningProgressListenerState();
}

class _ListeningProgressListenerState
    extends ConsumerState<ListeningProgressListener> {
  bool _showing = false;

  Future<void> _showConflict() async {
    if (_showing || !mounted) return;
    final conflict = ref.read(listeningProgressControllerProvider);
    final local = conflict.localConflict;
    final remote = conflict.remoteConflict;
    if (local == null || remote == null) return;
    _showing = true;
    final BuildContext? navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) {
      _showing = false;
      return;
    }
    try {
      final bool? useLocal = await showDialog<bool>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('选择收听进度'),
          content: Text(
            '本地有尚未同步的记录，B站未提供可比较的更新时间。\n本地：${_time(local.positionMs)}\nB站：${_time(remote.positionMs)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('使用本地'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('使用B站'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      final controller = ref.read(listeningProgressControllerProvider.notifier);
      final position = await controller.resolveConflict(
        useLocal: useLocal ?? false,
        expectedLocal: local,
        expectedRemote: remote,
      );
      if (!mounted || position == null) return;
      final player = ref.read(playerControllerProvider);
      if (controller.accountId == local.accountId &&
          player.currentItem?.isSpoken == true &&
          player.currentItem?.collectionId == local.collectionId &&
          player.currentItem != null &&
          local.matchesChapter(player.currentItem!) &&
          player.isReady) {
        await ref.read(playerControllerProvider.notifier).seek(position);
      }
    } on Object {
      if (mounted) ToastUtil.show('收听进度保存失败，请重试');
    } finally {
      _showing = false;
      if (mounted &&
          ref.read(listeningProgressControllerProvider).localConflict != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showConflict());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(listeningProgressControllerProvider, (previous, next) {
      if (next.localConflict != null &&
          next.localConflict != previous?.localConflict) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showConflict());
      }
    });
    return widget.child;
  }
}

String _time(int milliseconds) {
  final int seconds = milliseconds ~/ 1000;
  return '${seconds ~/ 3600}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
