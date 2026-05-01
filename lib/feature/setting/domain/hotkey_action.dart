enum HotkeyAction {
  playPause,
  previousTrack,
  nextTrack,
  toggleDesktop;

  String get title {
    return switch (this) {
      HotkeyAction.playPause => '播放/暂停',
      HotkeyAction.previousTrack => '上一首',
      HotkeyAction.nextTrack => '下一首',
      HotkeyAction.toggleDesktop => '显示/隐藏桌面',
    };
  }

  String get description {
    return switch (this) {
      HotkeyAction.playPause => '切换当前播放状态',
      HotkeyAction.previousTrack => '跳转到上一首歌曲',
      HotkeyAction.nextTrack => '跳转到下一首歌曲',
      HotkeyAction.toggleDesktop => '显示或隐藏主窗口',
    };
  }
}
