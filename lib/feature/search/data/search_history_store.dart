import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_store.g.dart';

@riverpod
SearchHistoryStore searchHistoryStore(Ref ref) {
  return SearchHistoryStore(Hive.box<String>('prefs'));
}

class SearchHistoryStore {
  const SearchHistoryStore(this._prefsBox);

  static const String _historyKey = 'search.history';

  final Box<String> _prefsBox;

  List<String> load() {
    final String rawValue =
        _prefsBox.get(_historyKey, defaultValue: '[]') ?? '[]';

    try {
      final List<dynamic> decoded = jsonDecode(rawValue) as List<dynamic>;
      return decoded
          .whereType<String>()
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .take(20)
          .toList();
    } on FormatException {
      return <String>[];
    }
  }

  Future<void> save(List<String> keywords) {
    final List<String> sanitized = keywords
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .take(20)
        .toList();
    return _prefsBox.put(_historyKey, jsonEncode(sanitized));
  }

  Future<void> clear() {
    return _prefsBox.delete(_historyKey);
  }
}
