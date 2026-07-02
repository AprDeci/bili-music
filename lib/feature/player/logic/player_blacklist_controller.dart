import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_blacklist_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_blacklist_controller.g.dart';

const int _maxPlayerBlacklistEntries = 1000;

@Riverpod(keepAlive: true)
class PlayerBlacklistController extends _$PlayerBlacklistController {
  @override
  List<PlayerBlacklistEntry> build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return _decodeEntries(
      settingsStore.readString(
        HiveKeys.playerBlacklistEntries,
        defaultValue: '[]',
      ),
    );
  }

  bool containsItem(PlayableItem item) {
    return containsStableId(item.stableId);
  }

  bool containsStableId(String stableId) {
    return state.any(
      (PlayerBlacklistEntry entry) => entry.stableId == stableId,
    );
  }

  List<PlayableItem> filterAllowedItems(Iterable<PlayableItem> items) {
    final Set<String> blockedIds = state
        .map((PlayerBlacklistEntry entry) => entry.stableId)
        .toSet();
    return items
        .where((PlayableItem item) => !blockedIds.contains(item.stableId))
        .toList(growable: false);
  }

  Future<bool> addItem(PlayableItem item) async {
    final PlayerBlacklistEntry nextEntry =
        PlayerBlacklistEntry.fromPlayableItem(item);
    final int existingIndex = state.indexWhere(
      (PlayerBlacklistEntry entry) => entry.stableId == nextEntry.stableId,
    );

    final List<PlayerBlacklistEntry> nextEntries =
        List<PlayerBlacklistEntry>.of(state);
    if (existingIndex >= 0) {
      final PlayerBlacklistEntry existing = nextEntries.removeAt(existingIndex);
      nextEntries.insert(
        0,
        nextEntry.copyWith(addedAtEpochMs: existing.addedAtEpochMs),
      );
      state = List<PlayerBlacklistEntry>.unmodifiable(nextEntries);
      await _persist();
      return false;
    }

    nextEntries.insert(0, nextEntry);
    state = List<PlayerBlacklistEntry>.unmodifiable(
      nextEntries.take(_maxPlayerBlacklistEntries),
    );
    await _persist();
    return true;
  }

  Future<void> removeByStableId(String stableId) async {
    final List<PlayerBlacklistEntry> nextEntries = state
        .where((PlayerBlacklistEntry entry) => entry.stableId != stableId)
        .toList(growable: false);
    if (nextEntries.length == state.length) {
      return;
    }
    state = List<PlayerBlacklistEntry>.unmodifiable(nextEntries);
    await _persist();
  }

  Future<void> clear() async {
    if (state.isEmpty) {
      return;
    }
    state = const <PlayerBlacklistEntry>[];
    await _persist();
  }

  Future<void> _persist() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    final List<Map<String, dynamic>> encoded = state
        .map((PlayerBlacklistEntry entry) => entry.toJson())
        .toList(growable: false);
    return settingsStore.writeString(
      HiveKeys.playerBlacklistEntries,
      jsonEncode(encoded),
    );
  }

  List<PlayerBlacklistEntry> _decodeEntries(String rawValue) {
    try {
      final Object? decoded = jsonDecode(rawValue);
      if (decoded is! List<dynamic>) {
        return const <PlayerBlacklistEntry>[];
      }

      final Map<String, PlayerBlacklistEntry> entriesById =
          <String, PlayerBlacklistEntry>{};
      for (final Object? item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final PlayerBlacklistEntry entry = PlayerBlacklistEntry.fromJson(item);
        if (entry.stableId.trim().isEmpty) {
          continue;
        }
        entriesById.putIfAbsent(entry.stableId, () => entry);
      }

      return List<PlayerBlacklistEntry>.unmodifiable(
        entriesById.values.take(_maxPlayerBlacklistEntries),
      );
    } on Object {
      return const <PlayerBlacklistEntry>[];
    }
  }
}
