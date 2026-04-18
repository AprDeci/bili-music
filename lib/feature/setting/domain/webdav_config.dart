import 'package:freezed_annotation/freezed_annotation.dart';

part 'webdav_config.freezed.dart';

@freezed
abstract class WebDavConfig with _$WebDavConfig {
  const factory WebDavConfig({
    @Default('') String baseUrl,
    @Default('') String username,
    @Default('') String password,
  }) = _WebDavConfig;

  const WebDavConfig._();

  bool get isConfigured {
    return baseUrl.trim().isNotEmpty &&
        username.trim().isNotEmpty &&
        password.isNotEmpty;
  }
}
