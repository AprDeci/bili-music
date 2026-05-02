import 'package:bilimusic/common/util/update_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String issueUrl = 'https://github.com/AprDeci/bili-music/issues/new';
    final String sourceCodeUrl = 'https://github.com/AprDeci/bili-music';

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AboutHero(),
            const SizedBox(height: 24),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                    final String versionLabel = snapshot.hasData
                        ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                        : '读取中';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.commit_outlined),
                      title: const Text('版本信息'),
                      subtitle: Text(
                        '当前应用版本',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Text(versionLabel),
                    );
                  },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.system_update_alt_outlined),
              title: const Text('检查更新'),
              subtitle: Text('查看是否有新版本', style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_outlined),
              onTap: () =>
                  UpdateUtil.checkAndPromptForUpdate(context, manual: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('问题反馈'),
              subtitle: Text('联系或提交问题反馈', style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_outlined),
              onTap: () {
                launchUrl(Uri.parse(issueUrl));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code_outlined),
              title: const Text('Source Code'),
              subtitle: Text('查看源代码仓库', style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_outlined),
              onTap: () {
                launchUrl(Uri.parse(sourceCodeUrl));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutHero extends StatelessWidget {
  const AboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset('assets/icons/icon3.png'),
        ),
        const SizedBox(height: 24),
        Text(
          'Bili-Music',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text('Bilibili 音乐播放器', style: theme.textTheme.bodySmall),
      ],
    );
  }
}
