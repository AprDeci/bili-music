class BiliUpException implements Exception {
  const BiliUpException(this.message);

  final String message;

  @override
  String toString() => message;
}
