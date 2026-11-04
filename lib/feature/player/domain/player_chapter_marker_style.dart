enum PlayerChapterMarkerStyle {
  line,
  dot;

  String get label => switch (this) {
    PlayerChapterMarkerStyle.line => '竖线',
    PlayerChapterMarkerStyle.dot => '圆点',
  };

  String get description => switch (this) {
    PlayerChapterMarkerStyle.line => '在进度条上用细竖线标记每首歌的起点',
    PlayerChapterMarkerStyle.dot => '在进度条上用圆点标记每首歌的起点',
  };

  static PlayerChapterMarkerStyle fromStorage(String? value) {
    for (final PlayerChapterMarkerStyle style
        in PlayerChapterMarkerStyle.values) {
      if (style.name == value) {
        return style;
      }
    }
    return PlayerChapterMarkerStyle.line;
  }
}
