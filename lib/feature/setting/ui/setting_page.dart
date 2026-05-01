import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
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
                title: const Text('缓存设置'),
                subtitle: Text(
                  '管理图片与音频缓存 · ${formatBytes(snapshot.data ?? 0)}',
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
