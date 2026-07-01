enum MultiPartQueuePreference {
  currentPart('current_part'),
  allParts('all_parts');

  const MultiPartQueuePreference(this.storageValue);

  final String storageValue;

  String get title {
    return switch (this) {
      MultiPartQueuePreference.currentPart => '默认添加首个分段',
      MultiPartQueuePreference.allParts => '默认添加所有分段',
    };
  }

  String get description {
    return switch (this) {
      MultiPartQueuePreference.currentPart => '分段视频只添加首个分段到播放队列。',
      MultiPartQueuePreference.allParts => '分段视频会将所有分段添加到播放队列。',
    };
  }
}

MultiPartQueuePreference multiPartQueuePreferenceFromStorage(String value) {
  for (final MultiPartQueuePreference preference
      in MultiPartQueuePreference.values) {
    if (preference.storageValue == value) {
      return preference;
    }
  }
  return MultiPartQueuePreference.currentPart;
}
