class MobileChromeConfig {
  const MobileChromeConfig({
    required this.showBottomTabs,
    required this.showMiniPlayer,
  });

  final bool showBottomTabs;
  final bool showMiniPlayer;

  /// 主页面配置
  static const MobileChromeConfig mainTab = MobileChromeConfig(
    showBottomTabs: true,
    showMiniPlayer: true,
  );

  // 不显示底部导航
  static const MobileChromeConfig detail = MobileChromeConfig(
    showBottomTabs: false,
    showMiniPlayer: true,
  );

  // 什么也不显示
  static const MobileChromeConfig fullScreen = MobileChromeConfig(
    showBottomTabs: false,
    showMiniPlayer: false,
  );

  static MobileChromeConfig resolve(String path) {
    if (path == '/player') {
      return fullScreen;
    }

    if (path == '/comments' || path == '/search' || path.startsWith('/up')) {
      return detail;
    }

    if (path == '/settings' || path.startsWith('/settings/')) {
      return fullScreen;
    }

    if (path == '/profile/import' || path.startsWith('/profile/favorites/')) {
      return detail;
    }

    return mainTab;
  }
}
