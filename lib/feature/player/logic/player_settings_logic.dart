import 'package:hive_ce/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<PlayerSettingsLogic, bool> playerSettingsLogicProvider =
    NotifierProvider<PlayerSettingsLogic, bool>(PlayerSettingsLogic.new);

class PlayerSettingsLogic extends Notifier<bool> {
  static const String _allowMixWithOthersKey = 'player.allow_mix_with_others';

  @override
  bool build() {
    final Box<String> prefsBox = Hive.box<String>('prefs');
    final String rawValue =
        prefsBox.get(_allowMixWithOthersKey, defaultValue: 'false') ?? 'false';
    return rawValue == 'true';
  }

  Future<void> setAllowMixWithOthers(bool value) async {
    await Hive.box<String>(
      'prefs',
    ).put(_allowMixWithOthersKey, value ? 'true' : 'false');
    state = value;
  }
}
