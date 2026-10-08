class BiliAuthRequiredException implements Exception {
  const BiliAuthRequiredException([this.message = '登录后可用']);

  final String message;

  @override
  String toString() => message;
}
