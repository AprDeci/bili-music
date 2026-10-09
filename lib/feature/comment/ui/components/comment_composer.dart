import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 未登录提示
Future<void> openCommentComposer({
  required BuildContext context,
  required WidgetRef ref,
  required Future<bool> Function(String message) onSubmit,
  CommentItem? replyTo,
}) async {
  final BiliSession? session = ref.read(biliSessionControllerProvider);
  if (session == null || !session.isLoggedIn) {
    ToastUtil.show('请先登录后再评论');
    context.push('/auth');
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _CommentComposerSheet(onSubmit: onSubmit, replyTo: replyTo);
    },
  );
}

class _CommentComposerSheet extends StatefulWidget {
  const _CommentComposerSheet({required this.onSubmit, this.replyTo});

  final Future<bool> Function(String message) onSubmit;
  final CommentItem? replyTo;

  @override
  State<_CommentComposerSheet> createState() => _CommentComposerSheetState();
}

class _CommentComposerSheetState extends State<_CommentComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_submitting && _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() => _submitting = true);
    final bool success = await widget.onSubmit(_controller.text);
    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final CommentItem? replyTo = widget.replyTo;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (replyTo != null) ...<Widget>[
                  Text(
                    '回复 @${replyTo.memberName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 1000,
                  readOnly: _submitting,
                  onChanged: (String _) => setState(() {}),
                  decoration: const InputDecoration(
                    isDense: true,
                    counterText: '',
                    hintText: '发一条友善的评论',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (_submitting)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: const Text('发送'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
