enum AudioCacheLimit {
  disabled(0, '关闭'),
  mb256(256 * 1024 * 1024, '256 MB'),
  mb512(512 * 1024 * 1024, '512 MB'),
  gb1(1024 * 1024 * 1024, '1 GB'),
  gb2(2 * 1024 * 1024 * 1024, '2 GB');

  const AudioCacheLimit(this.bytes, this.label);

  final int bytes;
  final String label;

  static AudioCacheLimit fromStorage(String value) => values.firstWhere(
    (AudioCacheLimit limit) => limit.name == value,
    orElse: () => mb512,
  );
}
