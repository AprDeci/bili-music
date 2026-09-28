import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<MetingSourceRule> rules = <MetingSourceRule>[
    MetingSourceRule(keyword: '周杰伦', server: MetingServer.tencent),
    MetingSourceRule(keyword: 'jay chou', server: MetingServer.tencent),
    MetingSourceRule(keyword: '林俊杰', server: MetingServer.kugou),
  ];

  group('resolveMetingServer', () {
    test('命中关键词时使用规则音源', () {
      expect(
        resolveMetingServer(
          text: '【4K修复】周杰伦 晴天',
          defaultServer: MetingServer.netease,
          rules: rules,
        ),
        MetingServer.tencent,
      );
    });

    test('匹配时不区分大小写', () {
      expect(
        resolveMetingServer(
          text: 'Jay Chou - 夜曲',
          defaultServer: MetingServer.netease,
          rules: rules,
        ),
        MetingServer.tencent,
      );
    });

    test('未命中时回落默认音源', () {
      expect(
        resolveMetingServer(
          text: '五月天 倔强',
          defaultServer: MetingServer.kugou,
          rules: rules,
        ),
        MetingServer.kugou,
      );
      expect(
        resolveMetingServer(
          text: '   ',
          defaultServer: MetingServer.tencent,
          rules: rules,
        ),
        MetingServer.tencent,
      );
      expect(
        resolveMetingServer(
          text: '周杰伦',
          defaultServer: MetingServer.netease,
          rules: const <MetingSourceRule>[],
        ),
        MetingServer.netease,
      );
    });

    test('按规则顺序取第一条命中', () {
      expect(
        resolveMetingServer(
          text: '周杰伦 x 林俊杰 合唱',
          defaultServer: MetingServer.netease,
          rules: rules,
        ),
        MetingServer.tencent,
      );
    });
  });

  group('规则序列化', () {
    test('编码后可以原样解码', () {
      expect(decodeMetingSourceRules(encodeMetingSourceRules(rules)), rules);
    });

    test('丢弃非法条目', () {
      expect(
        decodeMetingSourceRules(
          '["周杰伦", "=netease", "周杰伦=spotify", "五月天=kugou"]',
        ),
        <MetingSourceRule>[
          const MetingSourceRule(keyword: '五月天', server: MetingServer.kugou),
        ],
      );
    });

    test('空值与非 JSON 内容返回空列表', () {
      expect(decodeMetingSourceRules(''), isEmpty);
      expect(decodeMetingSourceRules('not json'), isEmpty);
      expect(decodeMetingSourceRules('"netease"'), isEmpty);
      expect(decodeMetingSourceRules('[]'), isEmpty);
    });
  });
}
