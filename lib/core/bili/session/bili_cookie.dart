import 'package:dio/dio.dart';

Map<String, String> extractCookiesFromHeaders(Headers headers) {
  final List<String> setCookies = headers.map['set-cookie'] ?? <String>[];
  final Map<String, String> cookies = <String, String>{};

  for (final String item in setCookies) {
    final String pair = item.split(';').first.trim();
    final int separator = pair.indexOf('=');
    if (separator <= 0) {
      continue;
    }

    final String name = pair.substring(0, separator).trim();
    final String value = pair.substring(separator + 1).trim();
    if (name.isNotEmpty && value.isNotEmpty) {
      cookies[name] = value;
    }
  }

  return cookies;
}

Map<String, String> parseCookieHeader(String cookie) {
  final Map<String, String> cookies = <String, String>{};
  if (cookie.isEmpty) {
    return cookies;
  }

  for (final String item in cookie.split(';')) {
    final String pair = item.trim();
    final int separator = pair.indexOf('=');
    if (separator <= 0) {
      continue;
    }

    final String name = pair.substring(0, separator).trim();
    final String value = pair.substring(separator + 1).trim();
    if (name.isNotEmpty && value.isNotEmpty) {
      cookies[name] = value;
    }
  }

  return cookies;
}

String buildCookieHeader(Map<String, String> cookies) {
  return cookies.entries
      .map((MapEntry<String, String> item) => '${item.key}=${item.value}')
      .join('; ');
}

String mergeCookieHeaders(String currentCookie, Map<String, String> nextCookies) {
  final Map<String, String> merged = parseCookieHeader(currentCookie);
  merged.addAll(nextCookies);
  return buildCookieHeader(merged);
}
