import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeningContinueButton extends ConsumerStatefulWidget {
  const ListeningContinueButton({
    super.key,
    required this.items,
    required this.onPlay,
  });

  final List<PlayableItem> items;
  final Future<void> Function(List<PlayableItem> items, int startIndex) onPlay;

  @override
  ConsumerState<ListeningContinueButton> createState() =>
      _ListeningContinueButtonState();
}

class _ListeningContinueButtonState
    extends ConsumerState<ListeningContinueButton> {
  bool _loading = false;

  Future<void> _continue() async {
    final List<PlayableItem> items = widget.items;
    final player = ref.read(playerControllerProvider);
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(listeningProgressControllerProvider.notifier)
          .continuation(items);
      if (!mounted || !listEquals(widget.items, items)) return;
      final current = ref.read(playerControllerProvider);
      if (current.currentItem != player.currentItem ||
          current.isLoading != player.isLoading ||
          current.isReady != player.isReady ||
          current.isPlaying != player.isPlaying ||
          !listEquals(current.queue, player.queue)) {
        return;
      }
      final String? warning = ref
          .read(listeningProgressControllerProvider)
          .warning;
      if (warning != null) ToastUtil.show(warning);
      await widget.onPlay(result.items, result.startIndex);
    } on Object {
      if (mounted) ToastUtil.show('无法继续收听，请重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? warning = ref
        .watch(listeningProgressControllerProvider)
        .warning;
    return Tooltip(
      message: warning ?? '同步B站历史并继续收听',
      child: TextButton.icon(
        onPressed: _loading || widget.items.isEmpty ? null : _continue,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                warning == null
                    ? Icons.play_arrow_rounded
                    : Icons.cloud_off_outlined,
                size: 18,
              ),
        label: const Text('继续收听'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: const Size(0, 32),
        ),
      ),
    );
  }
}
