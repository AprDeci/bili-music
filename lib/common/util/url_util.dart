String normalizeHttpUrl(String value) {
  if (value.isEmpty) {
    return '';
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('//')) {
    return 'https:$value';
  }
  return 'https://$value';
}
