import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_preference.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;
  late ProviderContainer container;

  MetingSourcePreference readPreference() =>
      container.read(metingSourcePreferenceLogicProvider);

  MetingSourcePreferenceLogic readLogic() =>
      container.read(metingSourcePreferenceLogicProvider.notifier);

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('meting-pref-test-');
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>(HiveBoxNames.prefs);
    container = ProviderContainer(
      overrides: [
        appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await prefsBox.close();
    await Hive.deleteBoxFromDisk(HiveBoxNames.prefs);
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('首次运行使用内置的周杰伦规则和网易云默认音源', () {
    final MetingSourcePreference preference = readPreference();

    expect(preference.defaultServer, MetingServer.netease);
    expect(preference.resolve('周杰伦 晴天'), MetingServer.tencent);
    expect(preference.resolve('五月天 倔强'), MetingServer.netease);
  });

  test('默认音源与规则写入后可以重新加载', () async {
    final MetingSourcePreferenceLogic logic = readLogic();
    await logic.setDefaultServer(MetingServer.tencent);
    await logic.upsertRule(keyword: '五月天', server: MetingServer.kugou);

    container.invalidate(metingSourcePreferenceLogicProvider);
    final MetingSourcePreference preference = readPreference();

    expect(preference.defaultServer, MetingServer.tencent);
    expect(preference.resolve('五月天 倔强'), MetingServer.kugou);
    expect(preference.resolve('随便一首'), MetingServer.tencent);
  });

  test('同关键词只保留一条规则，清空后不会回到内置规则', () async {
    final MetingSourcePreferenceLogic logic = readLogic();
    await logic.upsertRule(keyword: '周杰伦', server: MetingServer.netease);

    final List<MetingSourceRule> rules = readPreference().rules;
    expect(
      rules.where((MetingSourceRule rule) => rule.keyword == '周杰伦').length,
      1,
    );
    expect(readPreference().resolve('周杰伦 晴天'), MetingServer.netease);

    for (final MetingSourceRule rule in rules) {
      await logic.removeRule(rule);
    }
    container.invalidate(metingSourcePreferenceLogicProvider);

    expect(readPreference().rules, isEmpty);
    expect(readPreference().resolve('周杰伦 晴天'), MetingServer.netease);
  });
}
