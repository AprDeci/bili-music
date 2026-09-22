import 'package:bilimusic/core/bili/sign/bili_web_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hexsign 与文档给出的算法一致', () {
    // 期望值由文档 Demo 的 Node 实现算出：
    // crypto.createHmac('sha256', 'XgwSnGZ1p').update('ts1700000000').digest('hex')
    expect(
      biliTicketHexSign(1700000000),
      'bb79f0d980ffbb51597aa1a3e8b55603025cc1322ac766f4c1a98852e6182514',
    );
  });
}
