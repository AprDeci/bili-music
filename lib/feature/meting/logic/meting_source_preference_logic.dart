import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_preference.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_source_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class MetingSourcePreferenceLogic extends _$MetingSourcePreferenceLogic {
  @override
  MetingSourcePreference build() {
    final AppSettingsStore store = ref.read(appSettingsStoreProvider);
    final String rawRules = store.readString(
      HiveKeys.metingSourceRules,
      defaultValue: '',
    );
    return MetingSourcePreference(
      defaultServer: MetingServer.fromApiValue(
        store.readString(
          HiveKeys.metingDefaultServer,
          defaultValue: MetingServer.netease.apiValue,
        ),
      ),
      // 键不存在时用内置规则；用户清空规则后写入的是 '[]'，不会再被填充。
      rules: rawRules.isEmpty
          ? defaultMetingSourceRules
          : decodeMetingSourceRules(rawRules),
    );
  }

  Future<void> setDefaultServer(MetingServer server) async {
    if (server == state.defaultServer) {
      return;
    }
    state = state.copyWith(defaultServer: server);
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.metingDefaultServer, server.apiValue);
  }

  Future<void> upsertRule({
    required String keyword,
    required MetingServer server,
  }) async {
    final String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      return;
    }

    final String normalizedKeyword = trimmedKeyword.toLowerCase();
    await _persistRules(<MetingSourceRule>[
      for (final MetingSourceRule rule in state.rules)
        if (rule.keyword.toLowerCase() != normalizedKeyword) rule,
      MetingSourceRule(keyword: trimmedKeyword, server: server),
    ]);
  }

  Future<void> removeRule(MetingSourceRule rule) async {
    await _persistRules(<MetingSourceRule>[
      for (final MetingSourceRule item in state.rules)
        if (item != rule) item,
    ]);
  }

  Future<void> _persistRules(List<MetingSourceRule> rules) async {
    state = state.copyWith(rules: rules);
    await ref
        .read(appSettingsStoreProvider)
        .writeString(
          HiveKeys.metingSourceRules,
          encodeMetingSourceRules(rules),
        );
  }
}
