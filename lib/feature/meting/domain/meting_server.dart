enum MetingServer {
  netease('netease', '网易云音乐'),
  kugou('kugou', '酷狗音乐'),
  tencent('tencent', 'QQ音乐');

  const MetingServer(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MetingServer? tryFromApiValue(String value) {
    final String trimmed = value.trim();
    for (final MetingServer server in values) {
      if (server.apiValue == trimmed) {
        return server;
      }
    }
    return null;
  }

  static MetingServer fromApiValue(String value) =>
      tryFromApiValue(value) ?? netease;
}
