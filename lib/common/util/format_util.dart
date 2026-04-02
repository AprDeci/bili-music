String formatCompactCount(int value) {
  if (value >= 100000000) {
    return '${(value / 100000000).toStringAsFixed(1)}亿';
  }
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(1)}万';
  }
  return value.toString();
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
