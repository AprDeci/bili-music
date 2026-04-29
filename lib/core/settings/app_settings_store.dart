import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_settings_store.g.dart';

@riverpod
AppSettingsStore appSettingsStore(Ref ref) {
  return AppSettingsStore(Hive.box<String>(HiveBoxNames.prefs));
}

class AppSettingsStore {
  const AppSettingsStore(this._prefsBox);

  final Box<String> _prefsBox;

  String readString(String key, {required String defaultValue}) {
    return _prefsBox.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> writeString(String key, String value) {
    return _prefsBox.put(key, value);
  }

  bool readBool(String key, {required bool defaultValue}) {
    final String defaultRawValue = defaultValue ? 'true' : 'false';
    final String rawValue =
        _prefsBox.get(key, defaultValue: defaultRawValue) ?? defaultRawValue;
    return rawValue == 'true';
  }

  Future<void> writeBool(String key, bool value) {
    return _prefsBox.put(key, value ? 'true' : 'false');
  }

  double readDouble(String key, {required double defaultValue}) {
    final String defaultRawValue = defaultValue.toString();
    final String rawValue =
        _prefsBox.get(key, defaultValue: defaultRawValue) ?? defaultRawValue;
    return double.tryParse(rawValue) ?? defaultValue;
  }

  Future<void> writeDouble(String key, double value) {
    return _prefsBox.put(key, value.toString());
  }

  List<String> readStringList(String key, {int maxItems = 20}) {
    final String rawValue = _prefsBox.get(key, defaultValue: '[]') ?? '[]';

    try {
      final List<dynamic> decoded = jsonDecode(rawValue) as List<dynamic>;
      return decoded
          .whereType<String>()
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .take(maxItems)
          .toList();
    } on FormatException {
      return <String>[];
    }
  }

  Future<void> writeStringList(
    String key,
    List<String> values, {
    int maxItems = 20,
  }) {
    final List<String> sanitized = values
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .take(maxItems)
        .toList();
    return _prefsBox.put(key, jsonEncode(sanitized));
  }

  Future<void> remove(String key) {
    return _prefsBox.delete(key);
  }
}
