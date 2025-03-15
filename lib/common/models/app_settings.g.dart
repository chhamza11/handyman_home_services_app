// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    return AppSettings(
      isFirstLaunch: reader.readBool(),
      isLoggedIn: reader.readBool(),
      mode: AppMode.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.writeBool(obj.isFirstLaunch);
    writer.writeBool(obj.isLoggedIn);
    writer.writeInt(obj.mode.index);
  }
} 