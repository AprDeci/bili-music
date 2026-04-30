import 'package:bilimusic/feature/setting/domain/favorites_transfer_bundle.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_transfer_bundle.freezed.dart';
part 'app_transfer_bundle.g.dart';

@freezed
abstract class AppTransferBundle with _$AppTransferBundle {
  const AppTransferBundle._();

  const factory AppTransferBundle({
    @Default(2) int schemaVersion,
    required DateTime exportedAt,
    required FavoritesTransferBundle favorites,
    @Default(<String, String>{}) Map<String, String> settings,
  }) = _AppTransferBundle;

  factory AppTransferBundle.fromJson(Map<String, dynamic> json) =>
      _$AppTransferBundleFromJson(json);
}
