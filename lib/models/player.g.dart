// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 5;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
      maxHp: fields[2] as int,
      maxChakra: fields[4] as int,
      strength: fields[6] as int,
      defense: fields[7] as int,
      level: fields[9] as int,
      xp: fields[8] as int,
      availableJutsu: (fields[12] as List?)?.cast<Jutsu>(),
      inventory: (fields[13] as Map?)?.cast<String, InventoryEntry>(),
    )
      ..currentHp = fields[3] as int
      ..currentChakra = fields[5] as int
      ..xpToNextLevel = fields[10] as int
      ..isDefending = fields[11] as bool
      ..temporaryAttackBuff = fields[14] as int
      ..temporaryDefenseBuff = fields[15] as int;
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maxHp)
      ..writeByte(3)
      ..write(obj.currentHp)
      ..writeByte(4)
      ..write(obj.maxChakra)
      ..writeByte(5)
      ..write(obj.currentChakra)
      ..writeByte(6)
      ..write(obj.strength)
      ..writeByte(7)
      ..write(obj.defense)
      ..writeByte(8)
      ..write(obj.xp)
      ..writeByte(9)
      ..write(obj.level)
      ..writeByte(10)
      ..write(obj.xpToNextLevel)
      ..writeByte(11)
      ..write(obj.isDefending)
      ..writeByte(12)
      ..write(obj.availableJutsu)
      ..writeByte(13)
      ..write(obj.inventory)
      ..writeByte(14)
      ..write(obj.temporaryAttackBuff)
      ..writeByte(15)
      ..write(obj.temporaryDefenseBuff);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
