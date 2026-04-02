Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
    );
  }
  throw const FormatException('Expected a map value.');
}

Map<String, dynamic>? asNullableStringKeyedMap(dynamic value) {
  if (value == null) {
    return null;
  }
  try {
    return asStringKeyedMap(value);
  } on FormatException {
    return null;
  }
}

Map<String, dynamic> asStringKeyedMapOrEmpty(dynamic value) {
  return asNullableStringKeyedMap(value) ?? <String, dynamic>{};
}

List<Map<String, dynamic>> asListOfMaps(dynamic value) {
  final List<dynamic> list = value as List<dynamic>? ?? <dynamic>[];
  return list.whereType<Map>().map(asStringKeyedMap).toList();
}
