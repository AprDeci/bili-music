import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:hive_ce/hive.dart';

/// 记录用户已忽略的 release tag，避免自动检查对同一版本反复弹窗。
class UpdateDismissedStore {
  const UpdateDismissedStore();

  String? load() {
    final String value =
        Hive.box<String>(
          HiveBoxNames.prefs,
        ).get(HiveKeys.updateDismissedTag, defaultValue: '') ??
        '';
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> save(String tagName) {
    return Hive.box<String>(
      HiveBoxNames.prefs,
    ).put(HiveKeys.updateDismissedTag, tagName);
  }
}
