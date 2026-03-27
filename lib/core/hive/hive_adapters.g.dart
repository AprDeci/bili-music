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
    );
  }

  @override
  void write(BinaryWriter writer, ThemeUiModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.themeMode);
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
      durationText: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteEntry obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.updatedAt);
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
