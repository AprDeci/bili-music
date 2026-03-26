class AudioStreamInfo {
  const AudioStreamInfo({
    required this.streamUrl,
    required this.backupUrls,
    required this.headers,
    required this.cid,
    required this.duration,
    this.pageTitle,
    this.qualityLabel,
  });

  final String streamUrl;
  final List<String> backupUrls;
  final Map<String, String> headers;
  final int cid;
  final Duration? duration;
  final String? pageTitle;
  final String? qualityLabel;
}
