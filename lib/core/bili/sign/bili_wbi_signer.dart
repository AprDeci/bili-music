import 'dart:convert';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_wbi_signer.g.dart';

@riverpod
BiliWbiSigner biliWbiSigner(Ref ref) {
  return const BiliWbiSigner();
}

class BiliWbiSigner {
  const BiliWbiSigner();

  static const List<int> _mixinKeyEncTab = <int>[
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52,
  ];

  Map<String, dynamic> sign({
    required Map<String, dynamic> queryParameters,
    required BiliSession session,
    int? timestamp,
  }) {
    final String imgKey = session.imgKey ?? '';
    final String subKey = session.subKey ?? '';
    if (imgKey.isEmpty || subKey.isEmpty) {
      throw const BiliWbiSignException('Missing WBI keys in current session.');
    }

    final String mixinKey = _getMixinKey(imgKey + subKey);
    final int wts = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final Map<String, String> normalized = <String, String>{
      for (final MapEntry<String, dynamic> entry in queryParameters.entries)
        entry.key: _normalizeValue(entry.value),
      'wts': wts.toString(),
    };

    final List<String> keys = normalized.keys.toList()..sort();
    final String query = keys
        .map(
          (String key) =>
              '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(normalized[key]!)}',
        )
        .join('&');

    final String wRid = md5.convert(utf8.encode(query + mixinKey)).toString();
    return <String, dynamic>{
      ...queryParameters,
      'wts': wts,
      'w_rid': wRid,
    };
  }

  String _getMixinKey(String raw) {
    final StringBuffer buffer = StringBuffer();
    for (final int index in _mixinKeyEncTab) {
      if (index >= raw.length) {
        continue;
      }
      buffer.write(raw[index]);
      if (buffer.length >= 32) {
        break;
      }
    }
    return buffer.toString();
  }

  String _normalizeValue(dynamic value) {
    final String stringValue = value?.toString() ?? '';
    return stringValue.replaceAll(RegExp(r"[!'()*]"), '');
  }
}

class BiliWbiSignException implements Exception {
  const BiliWbiSignException(this.message);

  final String message;

  @override
  String toString() => message;
}
