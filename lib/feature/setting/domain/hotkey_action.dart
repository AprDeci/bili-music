enum HotkeyAction {
  playPause,
  foregroundPlayPause,
  previousTrack,
  nextTrack,
  toggleDesktop;

  String get title {
    return switch (this) {
      HotkeyAction.playPause => '播放/暂停（全局）',
      HotkeyAction.foregroundPlayPause => '播放/暂停（前台）',
      HotkeyAction.previousTrack => '上一首',
      HotkeyAction.nextTrack => '下一首',
      HotkeyAction.toggleDesktop => '显示/隐藏桌面',
    };
  }

  String get description {
    return switch (this) {
      HotkeyAction.playPause => '全局切换当前播放状态',
      HotkeyAction.foregroundPlayPause => '窗口在前台时切换当前播放状态',
      HotkeyAction.previousTrack => '跳转到上一首歌曲',
      HotkeyAction.nextTrack => '跳转到下一首歌曲',
      HotkeyAction.toggleDesktop => '显示或隐藏主窗口',
    };
  }
}
