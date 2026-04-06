import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  late Future<String> _cacheSizeFuture;

  @override
  void initState() {
    super.initState();
    _cacheSizeFuture = CacheUtil.getImageCacheSize();
  }

  Future<void> _reloadCacheSize() async {
    setState(() {
      _cacheSizeFuture = CacheUtil.getImageCacheSize();
    });
  }

  Future<void> _handleClearCache() async {
    final bool shouldClear = await _showClearCacheDialog(context) ?? false;
    if (!shouldClear) {
      return;
    }

    await CacheUtil.clearImageCache();
    await _reloadCacheSize();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('缓存已清理')));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_outlined),
            title: const Text('主题设置'),
            subtitle: Text(
              '跟随系统、浅色、深色与浅色主题选择',
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/theme'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.multitrack_audio_outlined),
            title: const Text('允许与其他应用同时播放'),
            subtitle: Text('重启后生效', style: theme.textTheme.bodySmall),
            value: allowMixWithOthers,
            onChanged: (bool value) async {
              await ref
                  .read(playerSettingsLogicProvider.notifier)
                  .setAllowMixWithOthers(value);
            },
          ),
          FutureBuilder<String>(
            future: _cacheSizeFuture,
            builder: (context, snapshot) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outlined),
                title: const Text('清理缓存'),
                subtitle: Text(
                  '${snapshot.data ?? '0'} MB',
                  style: theme.textTheme.bodySmall,
                ),
                onTap: _handleClearCache,
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

Future<bool?> _showClearCacheDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('确认清理缓存吗？'),
      content: const Text('缓存内容为图片'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('确认'),
        ),
      ],
    ),
  );
}
