/// 版本号比较，兼容 `v1.8.2`、`1.8.2-dev`、`1.8.2+12` 这类写法。
class UpdateVersion implements Comparable<UpdateVersion> {
  const UpdateVersion._(this.segments, this.displayValue);

  static UpdateVersion? tryParse(String rawValue) {
    String normalized = rawValue.trim();
    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.startsWith('v') || normalized.startsWith('V')) {
      normalized = normalized.substring(1);
    }

    normalized = normalized.split('+').first.split('-').first.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final List<String> parts = normalized.split('.');
    if (parts.isEmpty) {
      return null;
    }

    final List<int> segments = <int>[];
    for (final String part in parts) {
      final int? value = int.tryParse(part);
      if (value == null) {
        return null;
      }
      segments.add(value);
    }

    return UpdateVersion._(segments, normalized);
  }

  final List<int> segments;
  final String displayValue;

  @override
  int compareTo(UpdateVersion other) {
    final int length = segments.length > other.segments.length
        ? segments.length
        : other.segments.length;

    for (int index = 0; index < length; index++) {
      final int left = index < segments.length ? segments[index] : 0;
      final int right = index < other.segments.length
          ? other.segments[index]
          : 0;
      if (left != right) {
        return left.compareTo(right);
      }
    }

    return 0;
  }
}
