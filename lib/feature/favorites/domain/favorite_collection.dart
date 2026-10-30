import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_collection.freezed.dart';
part 'favorite_collection.g.dart';

enum FavoriteCollectionSource { local, remote }

@freezed
abstract class FavoriteCollection with _$FavoriteCollection {
  const FavoriteCollection._();

  const factory FavoriteCollection({
    required String id,
    required String name,
    @Default(FavoriteCollectionSource.local) FavoriteCollectionSource source,
    @Default(CollectionKind.music) CollectionKind kind,
    @Default(false) bool isSystem,
    String? remoteId,
    String? coverUrl,
    @Default(0) int itemCount,
    @Default(false) bool isManagedByApp,
    DateTime? lastSyncedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FavoriteCollection;

  factory FavoriteCollection.fromJson(Map<String, dynamic> json) =>
      _$FavoriteCollectionFromJson(json);

  static const String likedCollectionId = 'liked';

  static String remoteCollectionId(String remoteId) => 'remote:$remoteId';

  bool get isLikedCollection => id == likedCollectionId;

  bool get isLocal => source == FavoriteCollectionSource.local;

  bool get isRemote => source == FavoriteCollectionSource.remote;

  static FavoriteCollection liked({DateTime? now}) {
    final DateTime timestamp = now ?? DateTime.now();
    return FavoriteCollection(
      id: likedCollectionId,
      name: '我喜欢',
      source: FavoriteCollectionSource.local,
      isSystem: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }
}
