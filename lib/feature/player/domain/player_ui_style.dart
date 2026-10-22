enum PlayerUiStyle { classic, appleMusic }

extension PlayerUiStyleX on PlayerUiStyle {
  String get storageValue => switch (this) {
    PlayerUiStyle.classic => 'classic',
    PlayerUiStyle.appleMusic => 'appleMusic',
  };

  String get title => switch (this) {
    PlayerUiStyle.classic => '经典',
    PlayerUiStyle.appleMusic => 'Apple Music',
  };
}

PlayerUiStyle playerUiStyleFromStorage(String value) {
  return switch (value) {
    'appleMusic' => PlayerUiStyle.appleMusic,
    _ => PlayerUiStyle.classic,
  };
}
