import 'package:flutter/material.dart';
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
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (
              BuildContext context,
              AsyncSnapshot<PackageInfo> snapshot,
            ) {
              final String versionLabel = snapshot.hasData
                  ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                  : '读取中';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('版本信息'),
                subtitle: Text(
                  '当前应用版本',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(versionLabel),
              );
            },
          ),
        ],
      ),
    );
  }
}
