// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ThemeUiModelAdapter extends TypeAdapter<ThemeUiModel> {
  @override
  final typeId = 0;

  @override
  ThemeUiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeUiModel(
      themeMode: fields[0] == null ? ThemeMode.system : fields[0] as ThemeMode,
      themeVariant: fields[2] == null
          ? ThemeVariant.classicGreen
          : fields[2] as ThemeVariant,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeUiModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.themeVariant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeUiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteCollectionAdapter extends TypeAdapter<FavoriteCollection> {
  @override
  final typeId = 1;

  @override
  FavoriteCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      isSystem: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteCollection obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isSystem)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteEntryAdapter extends TypeAdapter<FavoriteEntry> {
  @override
  final typeId = 2;

  @override
  FavoriteEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteEntry(
      itemId: fields[0] as String,
      aid: (fields[1] as num).toInt(),
      bvid: fields[2] as String,
      title: fields[3] as String,
      author: fields[4] as String,
      coverUrl: fields[5] as String,
      cid: (fields[9] as num?)?.toInt(),
      page: (fields[10] as num?)?.toInt(),
      pageTitle: fields[11] as String?,
      durationText: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.aid)
      ..writeByte(2)
      ..write(obj.bvid)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.author)
      ..writeByte(5)
      ..write(obj.coverUrl)
      ..writeByte(6)
      ..write(obj.durationText)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.cid)
      ..writeByte(10)
      ..write(obj.page)
      ..writeByte(11)
      ..write(obj.pageTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteMembershipAdapter extends TypeAdapter<FavoriteMembership> {
  @override
  final typeId = 3;

  @override
  FavoriteMembership read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMembership(
      id: fields[0] as String,
      collectionId: fields[1] as String,
      itemId: fields[2] as String,
      addedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMembership obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collectionId)
      ..writeByte(2)
      ..write(obj.itemId)
      ..writeByte(3)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMembershipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerQueueModeAdapter extends TypeAdapter<PlayerQueueMode> {
  @override
  final typeId = 4;

  @override
  PlayerQueueMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayerQueueMode.sequence;
      case 1:
        return PlayerQueueMode.singleRepeat;
      case 2:
        return PlayerQueueMode.shuffle;
      default:
        return PlayerQueueMode.sequence;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerQueueMode obj) {
    switch (obj) {
      case PlayerQueueMode.sequence:
        writer.writeByte(0);
      case PlayerQueueMode.singleRepeat:
        writer.writeByte(1);
      case PlayerQueueMode.shuffle:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerQueueModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersistedPlayableItemAdapter extends TypeAdapter<PersistedPlayableItem> {
  @override
  final typeId = 5;

  @override
  PersistedPlayableItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersistedPlayableItem(
      aid: (fields[0] as num).toInt(),
      bvid: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      coverUrl: fields[4] as String,
      cid: (fields[5] as num?)?.toInt(),
      page: (fields[6] as num?)?.toInt(),
      pageTitle: fields[7] as String?,
      durationText: fields[8] as String?,
      playCountText: fields[9] as String?,
      danmakuCountText: fields[10] as String?,
      likeCountText: fields[11] as String?,
      coinCountText: fields[12] as String?,
      favoriteCountText: fields[13] as String?,
      shareCountText: fields[14] as String?,
      replyCount: (fields[18] as num?)?.toInt(),
      replyCountText: fields[15] as String?,
      publishTimeText: fields[16] as String?,
      description: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersistedPlayableItem obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.aid)
      ..writeByte(1)
      ..write(obj.bvid)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.cid)
      ..writeByte(6)
      ..write(obj.page)
      ..writeByte(7)
      ..write(obj.pageTitle)
      ..writeByte(8)
      ..write(obj.durationText)
      ..writeByte(9)
      ..write(obj.playCountText)
      ..writeByte(10)
      ..write(obj.danmakuCountText)
      ..writeByte(11)
      ..write(obj.likeCountText)
      ..writeByte(12)
      ..write(obj.coinCountText)
      ..writeByte(13)
      ..write(obj.favoriteCountText)
      ..writeByte(14)
      ..write(obj.shareCountText)
      ..writeByte(15)
      ..write(obj.replyCountText)
      ..writeByte(16)
      ..write(obj.publishTimeText)
      ..writeByte(17)
      ..write(obj.description)
      ..writeByte(18)
      ..write(obj.replyCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedPlayableItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersistedPlaybackQueueAdapter
    extends TypeAdapter<PersistedPlaybackQueue> {
  @override
  final typeId = 6;

  @override
  PersistedPlaybackQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersistedPlaybackQueue(
      queue: fields[0] == null
          ? []
          : (fields[0] as List).cast<PersistedPlayableItem>(),
      currentQueueIndex: (fields[1] as num?)?.toInt(),
      queueMode: fields[2] == null
          ? PlayerQueueMode.sequence
          : fields[2] as PlayerQueueMode,
      queueSourceLabel: fields[3] as String?,
      resumePositionMs: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      savedAtEpochMs: (fields[5] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PersistedPlaybackQueue obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.queue)
      ..writeByte(1)
      ..write(obj.currentQueueIndex)
      ..writeByte(2)
      ..write(obj.queueMode)
      ..writeByte(3)
      ..write(obj.queueSourceLabel)
      ..writeByte(4)
      ..write(obj.resumePositionMs)
      ..writeByte(5)
      ..write(obj.savedAtEpochMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedPlaybackQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecentPlaybackEntryAdapter extends TypeAdapter<RecentPlaybackEntry> {
  @override
  final typeId = 7;

  @override
  RecentPlaybackEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentPlaybackEntry(
      aid: (fields[0] as num).toInt(),
      bvid: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      coverUrl: fields[4] as String,
      cid: (fields[5] as num?)?.toInt(),
      pageTitle: fields[6] as String?,
      playedAtEpochMs: (fields[7] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, RecentPlaybackEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.aid)
      ..writeByte(1)
      ..write(obj.bvid)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.cid)
      ..writeByte(6)
      ..write(obj.pageTitle)
      ..writeByte(7)
      ..write(obj.playedAtEpochMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentPlaybackEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
