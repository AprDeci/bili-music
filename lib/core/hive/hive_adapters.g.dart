// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ThemeUiModelAdapter extends TypeAdapter<ThemeUiModel> {
  @override
  final typeId = 2;

  @override
  ThemeUiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeUiModel(
      themeMode: fields[1] == null ? ThemeMode.system : fields[1] as ThemeMode,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeUiModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
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
