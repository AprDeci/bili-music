String formatCompactCount(int value) {
  if (value >= 100000000) {
    return '${(value / 100000000).toStringAsFixed(1)}亿';
  }
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(1)}万';
  }
  return value.toString();
}

String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  const int kb = 1024;
  const int mb = 1024 * 1024;
  const int gb = 1024 * 1024 * 1024;

  if (bytes < mb) {
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }

  if (bytes < gb) {
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }

  return '${(bytes / gb).toStringAsFixed(2)} GB';
}

String? formatYyyyMmDdFromUnixSeconds(int timestamp) {
  if (timestamp <= 0) {
    return null;
  }

  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    timestamp * 1000,
  );
  final String year = dateTime.year.toString().padLeft(4, '0');
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
