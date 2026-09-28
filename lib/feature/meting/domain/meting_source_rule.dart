import 'dart:convert';

import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meting_source_rule.freezed.dart';

/// 「关键词/歌手 → 歌词音源」映射规则。
@freezed
abstract class MetingSourceRule with _$MetingSourceRule {
  const factory MetingSourceRule({
    required String keyword,
    required MetingServer server,
  }) = _MetingSourceRule;
}

/// 首次运行时内置的规则，用户可在设置页编辑或删除。
const List<MetingSourceRule> defaultMetingSourceRules = <MetingSourceRule>[
  MetingSourceRule(keyword: '周杰伦', server: MetingServer.tencent),
  MetingSourceRule(keyword: 'jay chou', server: MetingServer.tencent),
];

/// 按规则顺序做不区分大小写的包含匹配，未命中时用默认音源。
MetingServer resolveMetingServer({
  required String text,
  required MetingServer defaultServer,
  required List<MetingSourceRule> rules,
}) {
  final String normalizedText = text.toLowerCase();
  if (normalizedText.trim().isEmpty) {
    return defaultServer;
  }

  for (final MetingSourceRule rule in rules) {
    final String keyword = rule.keyword.trim().toLowerCase();
    if (keyword.isNotEmpty && normalizedText.contains(keyword)) {
      return rule.server;
    }
  }

  return defaultServer;
}

/// 规则列表序列化为 JSON 字符串数组，例如 `["周杰伦=tencent"]`。
String encodeMetingSourceRules(List<MetingSourceRule> rules) {
  return jsonEncode(<String>[
    for (final MetingSourceRule rule in rules)
      '${rule.keyword}=${rule.server.apiValue}',
  ]);
}

/// 解析 [encodeMetingSourceRules] 的输出，非法条目直接丢弃。
List<MetingSourceRule> decodeMetingSourceRules(String rawJson) {
  if (rawJson.trim().isEmpty) {
    return const <MetingSourceRule>[];
  }

  try {
    final Object? decoded = jsonDecode(rawJson);
    if (decoded is! List<dynamic>) {
      return const <MetingSourceRule>[];
    }
    return _decodeRuleList(decoded);
  } on FormatException {
    return const <MetingSourceRule>[];
  }
}

List<MetingSourceRule> _decodeRuleList(List<dynamic> entries) {
  final List<MetingSourceRule> rules = <MetingSourceRule>[];
  for (final Object? entry in entries) {
    if (entry is! String) {
      continue;
    }
    final int separatorIndex = entry.lastIndexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }
    final String keyword = entry.substring(0, separatorIndex).trim();
    final MetingServer? server = MetingServer.tryFromApiValue(
      entry.substring(separatorIndex + 1),
    );
    if (keyword.isEmpty || server == null) {
      continue;
    }
    rules.add(MetingSourceRule(keyword: keyword, server: server));
  }

  return rules;
}
