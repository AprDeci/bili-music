enum PlayerLyricFontPreference {
  appDefault,
  microsoftYaHei,
  simSun,
  kaiTi,
  simHei,
  monospace,
}

extension PlayerLyricFontPreferenceX on PlayerLyricFontPreference {
  String get storageValue => switch (this) {
    PlayerLyricFontPreference.appDefault => 'app_default',
    PlayerLyricFontPreference.microsoftYaHei => 'microsoft_yahei',
    PlayerLyricFontPreference.simSun => 'simsun',
    PlayerLyricFontPreference.kaiTi => 'kaiti',
    PlayerLyricFontPreference.simHei => 'simhei',
    PlayerLyricFontPreference.monospace => 'monospace',
  };

  String get title => switch (this) {
    PlayerLyricFontPreference.appDefault => '跟随应用',
    PlayerLyricFontPreference.microsoftYaHei => '微软雅黑',
    PlayerLyricFontPreference.simSun => '宋体',
    PlayerLyricFontPreference.kaiTi => '楷体',
    PlayerLyricFontPreference.simHei => '黑体',
    PlayerLyricFontPreference.monospace => '等宽字体',
  };

  String get description => switch (this) {
    PlayerLyricFontPreference.appDefault => '使用当前主题的默认字体',
    PlayerLyricFontPreference.microsoftYaHei => '使用 Windows 常见无衬线中文字体',
    PlayerLyricFontPreference.simSun => '使用传统衬线中文字体',
    PlayerLyricFontPreference.kaiTi => '使用楷体风格中文字体',
    PlayerLyricFontPreference.simHei => '使用黑体风格中文字体',
    PlayerLyricFontPreference.monospace => '使用等宽字体，适合对齐歌词',
  };

  String? get fontFamily => switch (this) {
    PlayerLyricFontPreference.appDefault => null,
    PlayerLyricFontPreference.microsoftYaHei => 'Microsoft YaHei UI',
    PlayerLyricFontPreference.simSun => 'SimSun',
    PlayerLyricFontPreference.kaiTi => 'KaiTi',
    PlayerLyricFontPreference.simHei => 'SimHei',
    PlayerLyricFontPreference.monospace => 'Consolas',
  };

  List<String>? get fontFamilyFallback => switch (this) {
    PlayerLyricFontPreference.appDefault => null,
    PlayerLyricFontPreference.microsoftYaHei => <String>[
      'Microsoft YaHei',
      'Noto Sans CJK SC',
      'PingFang SC',
      'sans-serif',
    ],
    PlayerLyricFontPreference.simSun => <String>[
      'Songti SC',
      'Noto Serif CJK SC',
      'serif',
    ],
    PlayerLyricFontPreference.kaiTi => <String>[
      'STKaiti',
      'KaiTi_GB2312',
      'serif',
    ],
    PlayerLyricFontPreference.simHei => <String>[
      'Microsoft JhengHei',
      'Noto Sans CJK SC',
      'sans-serif',
    ],
    PlayerLyricFontPreference.monospace => <String>['Courier New', 'monospace'],
  };
}

PlayerLyricFontPreference playerLyricFontPreferenceFromStorage(String value) {
  return switch (value) {
    'app_chinese' => PlayerLyricFontPreference.microsoftYaHei,
    'microsoft_yahei' => PlayerLyricFontPreference.microsoftYaHei,
    'serif' => PlayerLyricFontPreference.simSun,
    'simsun' => PlayerLyricFontPreference.simSun,
    'kaiti' => PlayerLyricFontPreference.kaiTi,
    'simhei' => PlayerLyricFontPreference.simHei,
    'monospace' => PlayerLyricFontPreference.monospace,
    _ => PlayerLyricFontPreference.appDefault,
  };
}
