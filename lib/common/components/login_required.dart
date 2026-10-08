import 'package:bilimusic/core/bili/session/bili_auth_required_exception.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool isAuthRequired(Object error) => error is BiliAuthRequiredException;

// 登录提醒：单例 + 冷却，翻页/并发失败只弹一次
class LoginPrompt {
  LoginPrompt._();

  static const Duration _cooldown = Duration(seconds: 10);

  static bool _showing = false;
  static DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  static void show(BuildContext context, {String reason = '该功能需要登录 B 站账号'}) {
    final DateTime now = DateTime.now();
    if (_showing || now.difference(_lastShown) < _cooldown) {
      return;
    }

    _showing = true;
    _lastShown = now;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('登录后可用'),
        content: Text(reason),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('以后再说'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/auth');
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    ).whenComplete(() => _showing = false);
  }

  // 非鉴权异常返回 false，交给调用方原处理
  static bool handle(BuildContext context, Object error, {String? reason}) {
    if (!isAuthRequired(error)) {
      return false;
    }
    show(context, reason: reason ?? '该功能需要登录 B 站账号');
    return true;
  }
}

// 登录提醒空态
class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({
    super.key,
    this.description = '登录后可用',
    this.icon = Icons.lock_outline_rounded,
  });

  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/auth'),
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }
}
