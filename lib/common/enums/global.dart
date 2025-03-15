import 'package:hive/hive.dart';

part 'global.g.dart';

@HiveType(typeId: 1)
enum AppMode {
  @HiveField(0)
  vendor,
  @HiveField(1)
  client,
}
