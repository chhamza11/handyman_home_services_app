import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:home_services/common/enums/global.dart';
import '../models/app_settings.dart';

class MainController with ChangeNotifier {
  late AppSettings _settings;

  MainController() {
    _loadSettings();
  }

  AppSettings get settings => _settings;

  void _loadSettings() {
    var box = Hive.box('appSettings');
    if (box.isEmpty) {
      _settings = AppSettings(
        isFirstLaunch: true,
        isLoggedIn: false,
        mode: AppMode.client,
      );
      box.put('settings', _settings);
    } else {
      _settings = box.get('settings');
    }
    notifyListeners();
  }

  void login() {
    _settings.isLoggedIn = true;
    notifyListeners();
  }

  void setMode(AppMode mode) {
    _settings.mode = mode;
    notifyListeners();
  }
}
