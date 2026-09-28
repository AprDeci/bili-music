import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meting_source_preference.freezed.dart';

/// 歌词/元信息音源偏好：默认平台 + 关键词规则。
@freezed
abstract class MetingSourcePreference with _$MetingSourcePreference {
  const factory MetingSourcePreference({
    @Default(MetingServer.netease) MetingServer defaultServer,
    @Default(<MetingSourceRule>[]) List<MetingSourceRule> rules,
  }) = _MetingSourcePreference;

  const MetingSourcePreference._();

  MetingServer resolve(String text) {
    return resolveMetingServer(
      text: text,
      defaultServer: defaultServer,
      rules: rules,
    );
  }
}
