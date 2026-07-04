class DesktopLyricsPayload {
  const DesktopLyricsPayload({
    required this.title,
    required this.currentLyric,
    required this.nextLyric,
    required this.isPlaying,
    required this.isFavorite,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.hasItem,
    required this.opacity,
    required this.alwaysOnTop,
  });

  final String title;
  final String currentLyric;
  final String nextLyric;
  final bool isPlaying;
  final bool isFavorite;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool hasItem;
  final double opacity;
  final bool alwaysOnTop;

  static const DesktopLyricsPayload empty = DesktopLyricsPayload(
    title: '桌面歌词',
    currentLyric: '暂无播放内容',
    nextLyric: '',
    isPlaying: false,
    isFavorite: false,
    canGoPrevious: false,
    canGoNext: false,
    hasItem: false,
    opacity: 0.86,
    alwaysOnTop: true,
  );

  factory DesktopLyricsPayload.fromJson(Map<String, dynamic> json) {
    return DesktopLyricsPayload(
      title: _readString(json['title'], '桌面歌词'),
      currentLyric: _readString(json['currentLyric'], '暂无播放内容'),
      nextLyric: _readString(json['nextLyric'], ''),
      isPlaying: json['isPlaying'] == true,
      isFavorite: json['isFavorite'] == true,
      canGoPrevious: json['canGoPrevious'] == true,
      canGoNext: json['canGoNext'] == true,
      hasItem: json['hasItem'] == true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.86,
      alwaysOnTop: json['alwaysOnTop'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'currentLyric': currentLyric,
      'nextLyric': nextLyric,
      'isPlaying': isPlaying,
      'isFavorite': isFavorite,
      'canGoPrevious': canGoPrevious,
      'canGoNext': canGoNext,
      'hasItem': hasItem,
      'opacity': opacity,
      'alwaysOnTop': alwaysOnTop,
    };
  }

  static String _readString(Object? value, String fallback) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

enum DesktopLyricsCommand {
  toggleFavorite,
  blacklist,
  previous,
  togglePlayback,
  next,
  toggleAlwaysOnTop,
  close,
}

extension DesktopLyricsCommandX on DesktopLyricsCommand {
  String get methodName => switch (this) {
    DesktopLyricsCommand.toggleFavorite => 'toggleFavorite',
    DesktopLyricsCommand.blacklist => 'blacklist',
    DesktopLyricsCommand.previous => 'previous',
    DesktopLyricsCommand.togglePlayback => 'togglePlayback',
    DesktopLyricsCommand.next => 'next',
    DesktopLyricsCommand.toggleAlwaysOnTop => 'toggleAlwaysOnTop',
    DesktopLyricsCommand.close => 'close',
  };
}

DesktopLyricsCommand? desktopLyricsCommandFromMethodName(String methodName) {
  return switch (methodName) {
    'toggleFavorite' => DesktopLyricsCommand.toggleFavorite,
    'blacklist' => DesktopLyricsCommand.blacklist,
    'previous' => DesktopLyricsCommand.previous,
    'togglePlayback' => DesktopLyricsCommand.togglePlayback,
    'next' => DesktopLyricsCommand.next,
    'toggleAlwaysOnTop' => DesktopLyricsCommand.toggleAlwaysOnTop,
    'close' => DesktopLyricsCommand.close,
    _ => null,
  };
}
