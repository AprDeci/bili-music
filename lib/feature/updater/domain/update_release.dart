import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_release.freezed.dart';

@freezed
abstract class UpdateAsset with _$UpdateAsset {
  const factory UpdateAsset({
    required String name,
    required String downloadUrl,
    @Default(0) int sizeBytes,
    String? sha256Hex,
  }) = _UpdateAsset;

  const UpdateAsset._();
}

@freezed
abstract class UpdateRelease with _$UpdateRelease {
  const factory UpdateRelease({
    required String tagName,
    required String title,
    required String body,
    required String htmlUrl,
    @Default(<UpdateAsset>[]) List<UpdateAsset> assets,
  }) = _UpdateRelease;

  const UpdateRelease._();

  /// 资产名形如 `bili-music-v1.8.2-arm64-v8a.apk`，按 [nameSuffixes] 顺序取第一个匹配。
  UpdateAsset? selectAsset(List<String> nameSuffixes) {
    for (final String suffix in nameSuffixes) {
      final String needle = '-${suffix.toLowerCase()}';
      for (final UpdateAsset asset in assets) {
        if (asset.name.toLowerCase().endsWith(needle)) {
          return asset;
        }
      }
    }
    return null;
  }
}
