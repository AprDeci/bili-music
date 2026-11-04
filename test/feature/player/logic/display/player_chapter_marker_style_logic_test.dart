import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/display/player_chapter_marker_style_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds the stored style', () {
    final _FakeSettingsStore store = _FakeSettingsStore('dot');
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(playerChapterMarkerStyleLogicProvider),
      PlayerChapterMarkerStyle.dot,
    );
  });

  test('falls back to line when nothing is stored', () {
    final _FakeSettingsStore store = _FakeSettingsStore('');
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(playerChapterMarkerStyleLogicProvider),
      PlayerChapterMarkerStyle.line,
    );
  });

  test('setStyle persists and updates state', () async {
    final _FakeSettingsStore store = _FakeSettingsStore('');
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await container
        .read(playerChapterMarkerStyleLogicProvider.notifier)
        .setStyle(PlayerChapterMarkerStyle.dot);

    expect(store.values['player.chapter_marker_style'], 'dot');
    expect(
      container.read(playerChapterMarkerStyleLogicProvider),
      PlayerChapterMarkerStyle.dot,
    );
  });
}

class _FakeSettingsStore implements AppSettingsStore {
  _FakeSettingsStore(this._stored);

  final String _stored;
  final Map<String, String> values = <String, String>{};

  @override
  String readString(String key, {required String defaultValue}) {
    return values[key] ?? (_stored.isEmpty ? defaultValue : _stored);
  }

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
