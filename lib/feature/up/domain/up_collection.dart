import 'package:freezed_annotation/freezed_annotation.dart';

part 'up_collection.freezed.dart';

@freezed
abstract class UpCollection with _$UpCollection {
  const factory UpCollection({
    required int seasonId,
    required int mid,
    required String title,
    required String coverUrl,
    required int total,
    String? description,
    DateTime? updatedAt,
  }) = _UpCollection;
}
