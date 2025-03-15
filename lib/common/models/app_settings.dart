import 'package:hive/hive.dart';
import '../enums/global.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isFirstLaunch;

  @HiveField(1)
  bool isLoggedIn;

  @HiveField(2)
  AppMode mode;

  AppSettings({
    required this.isFirstLaunch,
    required this.isLoggedIn,
    required this.mode,
  });

  factory AppSettings.initial() => AppSettings(
    isFirstLaunch: true,
    isLoggedIn: false,
    mode: AppMode.client,
  );
}
