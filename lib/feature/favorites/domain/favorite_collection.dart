import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_collection.freezed.dart';

@freezed
abstract class FavoriteCollection with _$FavoriteCollection {
  const FavoriteCollection._();

  const factory FavoriteCollection({
    required String id,
    required String name,
    required bool isSystem,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FavoriteCollection;

  static const String likedCollectionId = 'liked';

  bool get isLikedCollection => id == likedCollectionId;

  static FavoriteCollection liked({DateTime? now}) {
    final DateTime timestamp = now ?? DateTime.now();
    return FavoriteCollection(
      id: likedCollectionId,
      name: '我喜欢',
      isSystem: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }
}
