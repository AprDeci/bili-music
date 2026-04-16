class AudioQualityOption {
  const AudioQualityOption({
    required this.qualityId,
    required this.bandwidth,
    required this.label,
    this.isSelected = false,
  });

  final int? qualityId;
  final int bandwidth;
  final String label;
  final bool isSelected;

  AudioQualityOption copyWith({bool? isSelected}) {
    return AudioQualityOption(
      qualityId: qualityId,
      bandwidth: bandwidth,
      label: label,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class AudioStreamInfo {
  const AudioStreamInfo({
    required this.streamUrl,
    required this.backupUrls,
    required this.headers,
    required this.cid,
    required this.duration,
    required this.bandwidth,
    required this.availableQualities,
    this.pageTitle,
    this.qualityId,
    this.qualityLabel,
  });

  final String streamUrl;
  final List<String> backupUrls;
  final Map<String, String> headers;
  final int cid;
  final Duration? duration;
  final int bandwidth;
  final List<AudioQualityOption> availableQualities;
  final String? pageTitle;
  final int? qualityId;
  final String? qualityLabel;
}
