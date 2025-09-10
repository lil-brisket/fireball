// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jutsu.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JutsuAdapter extends TypeAdapter<Jutsu> {
  @override
  final int typeId = 3;

  @override
  Jutsu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Jutsu(
      name: fields[0] as String,
      chakraCost: fields[1] as int,
      minDamage: fields[2] as int,
      maxDamage: fields[3] as int,
      type: fields[4] as JutsuType,
      description: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Jutsu obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.chakraCost)
      ..writeByte(2)
      ..write(obj.minDamage)
      ..writeByte(3)
      ..write(obj.maxDamage)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JutsuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JutsuTypeAdapter extends TypeAdapter<JutsuType> {
  @override
  final int typeId = 4;

  @override
  JutsuType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JutsuType.ninjutsu;
      case 1:
        return JutsuType.taijutsu;
      case 2:
        return JutsuType.genjutsu;
      default:
        return JutsuType.ninjutsu;
    }
  }

  @override
  void write(BinaryWriter writer, JutsuType obj) {
    switch (obj) {
      case JutsuType.ninjutsu:
        writer.writeByte(0);
        break;
      case JutsuType.taijutsu:
        writer.writeByte(1);
        break;
      case JutsuType.genjutsu:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JutsuTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
