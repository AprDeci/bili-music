import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          if (kDebugMode)
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
