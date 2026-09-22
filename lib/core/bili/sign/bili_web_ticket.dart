import 'dart:convert';

import 'package:crypto/crypto.dart';

/// GenWebTicket 固定参数，见 `docs/bili-api-doc/docs/misc/sign/bili_ticket.md`。
const String biliTicketKeyId = 'ec02';

/// 计算 GenWebTicket 需要的 `hexsign`：`hmac_sha256('XgwSnGZ1p', 'ts<timestamp>')` 的十六进制值。
String biliTicketHexSign(int timestamp) {
  return Hmac(
    sha256,
    utf8.encode('XgwSnGZ1p'),
  ).convert(utf8.encode('ts$timestamp')).toString();
}
