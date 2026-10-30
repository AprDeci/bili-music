enum CollectionKind {
  music,
  spoken;

  String get label => switch (this) {
    CollectionKind.music => '歌曲',
    CollectionKind.spoken => '听声',
  };
}
