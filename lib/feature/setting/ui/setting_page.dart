import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  late Future<int> _cacheSizeFuture;

  @override
  void initState() {
    super.initState();
    _cacheSizeFuture = CacheUtil.getTotalCacheSizeBytes();
  }

  Future<void> _reloadCacheSize() async {
    setState(() {
      _cacheSizeFuture = CacheUtil.getTotalCacheSizeBytes();
    });
  }

  Future<bool> _confirm({
    required String title,
    required String content,
    required String confirmText,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  String _logoutMessage(LogoutResult result) {
    if (result.remoteLoggedOut) {
      return '已退出登录';
    }
    return result.message?.isNotEmpty == true
        ? '服务端退出失败，已清除本地登录状态'
        : '已清除本地登录状态';
  }

  Future<void> _handleLogoutPressed() async {
    final bool confirmed = await _confirm(
      title: '退出登录',
      content: '确认退出当前 B 站账号吗？',
      confirmText: '退出',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!mounted) {
      return;
    }
    ToastUtil.show(_logoutMessage(result));
  }

  Future<void> _handleSwitchAccount() async {
    final BiliSession? session = ref.read(biliSessionControllerProvider);
    final String accountName = session?.uname?.isNotEmpty == true
        ? session!.uname!
        : '当前账号';
    final bool confirmed = await _confirm(
      title: '切换账号',
      content: '将退出「$accountName」，随后使用新账号扫码登录。',
      confirmText: '继续',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!mounted) {
      return;
    }
    ToastUtil.show(
      result.remoteLoggedOut ? '已退出当前账号，请登录新账号' : '已清除本地登录状态，请登录新账号',
    );
    await context.push('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final String accountName = isLoggedIn
        ? (session?.uname?.isNotEmpty == true ? session!.uname! : '已登录 B 站账号')
        : '未登录';

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(accountName),
            subtitle: Text(
              isLoggedIn ? 'mid: ${session?.mid ?? '-'}' : '登录后可同步收藏与歌单',
              style: theme.textTheme.bodySmall,
            ),
            trailing: isLoggedIn
                ? null
                : const Icon(Icons.chevron_right_rounded),
            onTap: isLoggedIn ? null : () => context.push('/auth'),
          ),
          if (isLoggedIn)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('切换账号'),
              subtitle: Text(
                '退出当前账号并使用新账号登录',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _handleSwitchAccount,
            ),
          if (isLoggedIn)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                '退出登录',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: Text('清除本地登录状态', style: theme.textTheme.bodySmall),
              onTap: _handleLogoutPressed,
            ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_outlined),
            title: const Text('外观设置'),
            subtitle: Text('外观,主题选择', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/theme'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.multitrack_audio_outlined),
            title: const Text('播放器设置'),
            subtitle: Text('后台播放与音频策略', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/player'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.import_export_rounded),
            title: const Text('数据导入导出'),
            subtitle: Text('导出或导入收藏与应用设置', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/app-transfer'),
          ),
          if (PlatformUtil.isDesktop)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.keyboard_command_key_rounded),
              title: const Text('快捷键设置'),
              subtitle: Text('全局播放控制与窗口显示隐藏', style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings/hotkeys'),
            ),
          FutureBuilder<int>(
            future: _cacheSizeFuture,
            builder: (context, snapshot) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pie_chart_outline),
                title: const Text('缓存管理'),
                subtitle: Text(
                  '管理图片、音频、歌词与元信息缓存 · ${formatBytes(snapshot.data ?? 0)}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await context.push('/settings/cache');
                  if (!mounted) {
                    return;
                  }
                  await _reloadCacheSize();
                },
              );
            },
          ),

          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('关于'),
            subtitle: Text('关于应用', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }
}
