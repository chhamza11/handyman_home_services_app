import 'package:home_services/common/enums/global.dart';

class AppSettings {
  bool isFirstLaunch;
  bool isLoggedIn;
  AppMode mode;

  AppSettings({
    required this.isFirstLaunch,
    required this.isLoggedIn,
    required this.mode,
  });
}
