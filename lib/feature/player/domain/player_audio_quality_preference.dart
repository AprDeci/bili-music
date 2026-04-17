enum PlayerAudioQualityPreference { auto, hires, k192, k132 }

extension PlayerAudioQualityPreferenceX on PlayerAudioQualityPreference {
  String get storageValue => switch (this) {
    PlayerAudioQualityPreference.auto => 'auto',
    PlayerAudioQualityPreference.hires => 'hires',
    PlayerAudioQualityPreference.k192 => '192k',
    PlayerAudioQualityPreference.k132 => '132k',
  };

  String get title => switch (this) {
    PlayerAudioQualityPreference.auto => '自动',
    PlayerAudioQualityPreference.hires => 'Hi-Res',
    PlayerAudioQualityPreference.k192 => '192K',
    PlayerAudioQualityPreference.k132 => '132K',
  };

  String get description => switch (this) {
    PlayerAudioQualityPreference.auto => '优先播放当前可用最高码率',
    PlayerAudioQualityPreference.hires => '优先无损，未命中则回退到最高码率',
    PlayerAudioQualityPreference.k192 => '优先 192K，未命中则回退到最高码率',
    PlayerAudioQualityPreference.k132 => '优先 132K，未命中则回退到最高码率',
  };
}

PlayerAudioQualityPreference playerAudioQualityPreferenceFromStorage(
  String value,
) {
  return switch (value) {
    'hires' => PlayerAudioQualityPreference.hires,
    '192k' => PlayerAudioQualityPreference.k192,
    '132k' => PlayerAudioQualityPreference.k132,
    _ => PlayerAudioQualityPreference.auto,
  };
}
