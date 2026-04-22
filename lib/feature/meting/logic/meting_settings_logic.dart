import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/common/components/url_text_input.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meting_settings_logic.g.dart';

@Riverpod(keepAlive: true)
class MetingSettingsLogic extends _$MetingSettingsLogic {
  @override
  String build() {
    return _normalizeBaseUrl(
      ref
          .read(appSettingsStoreProvider)
          .readString(HiveKeys.metingBaseUrl, defaultValue: ''),
    );
  }

  Future<void> setBaseUrl(String value) async {
    final String normalized = _normalizeBaseUrl(value);
    state = normalized;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.metingBaseUrl, normalized);
  }

  String _normalizeBaseUrl(String value) {
    return normalizeHttpUrl(value);
  }
}
