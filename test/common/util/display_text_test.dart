import 'package:bilimusic/common/util/display_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores math bold letters used in bilibili titles', () {
    expect(
      normalizeDisplayText('【𝐇𝐢-𝐑𝐞𝐬无损臻享】《Hong Kong》'),
      '【Hi-Res无损臻享】《Hong Kong》',
    );
  });

  test('restores other math styles and digits', () {
    expect(normalizeDisplayText('𝓗𝓲-𝓡𝓮𝓼'), 'Hi-Res');
    expect(normalizeDisplayText('𝙃𝙞-𝙍𝙚𝙨'), 'Hi-Res');
    expect(normalizeDisplayText('𝕳𝖎-𝕽𝖊𝖘'), 'Hi-Res');
    expect(normalizeDisplayText('𝖧𝗂-𝖱𝖾𝗌'), 'Hi-Res');
    expect(normalizeDisplayText('Ｈｉ-Ｒｅｓ　１２３'), 'Hi-Res 123');
    expect(normalizeDisplayText('⓪①②③'), '⓪①②③');
  });

  test('keeps normal text untouched', () {
    expect(normalizeDisplayText('晴天 - 周杰伦'), '晴天 - 周杰伦');
    expect(normalizeDisplayText(''), '');
    expect(normalizeDisplayText('【Hi-Res无损】听最硬的曲'), '【Hi-Res无损】听最硬的曲');
  });

  test('is idempotent', () {
    const String fancy = '【𝐇𝐢-𝐑𝐞𝐬无损臻享】';
    final String once = normalizeDisplayText(fancy);
    expect(normalizeDisplayText(once), once);
  });
}
