enum PlayerLyricFontSizePreference { small, normal, large, extraLarge }

extension PlayerLyricFontSizePreferenceX on PlayerLyricFontSizePreference {
  String get storageValue => switch (this) {
    PlayerLyricFontSizePreference.small => 'small',
    PlayerLyricFontSizePreference.normal => 'normal',
    PlayerLyricFontSizePreference.large => 'large',
    PlayerLyricFontSizePreference.extraLarge => 'extra_large',
  };

  String get title => switch (this) {
    PlayerLyricFontSizePreference.small => '小',
    PlayerLyricFontSizePreference.normal => '标准',
    PlayerLyricFontSizePreference.large => '大',
    PlayerLyricFontSizePreference.extraLarge => '特大',
  };

  String get description => switch (this) {
    PlayerLyricFontSizePreference.small => '适合一屏显示更多歌词',
    PlayerLyricFontSizePreference.normal => '使用默认歌词字号',
    PlayerLyricFontSizePreference.large => '提高可读性',
    PlayerLyricFontSizePreference.extraLarge => '适合远距离查看',
  };

  double get scale => switch (this) {
    PlayerLyricFontSizePreference.small => 0.88,
    PlayerLyricFontSizePreference.normal => 1.0,
    PlayerLyricFontSizePreference.large => 1.14,
    PlayerLyricFontSizePreference.extraLarge => 1.3,
  };
}

PlayerLyricFontSizePreference playerLyricFontSizePreferenceFromStorage(
  String value,
) {
  return switch (value) {
    'small' => PlayerLyricFontSizePreference.small,
    'large' => PlayerLyricFontSizePreference.large,
    'extra_large' => PlayerLyricFontSizePreference.extraLarge,
    _ => PlayerLyricFontSizePreference.normal,
  };
}
