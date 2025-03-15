import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/common/enums/global.dart';
import '../models/app_settings.dart';
import 'auth_service.dart';
import 'user_provider.dart';

class MainController with ChangeNotifier {
  late AppSettings _settings;
  final AuthService _authService;
  final UserProvider _userProvider;
  final Box _box;

  MainController({
    required AuthService authService,
    required UserProvider userProvider,
    required Box box,
  }) : _authService = authService,
       _userProvider = userProvider,
       _box = box {
    _loadSettings();
    _initializeAuthListener();
  }

  AppSettings get settings => _settings;

  void _initializeAuthListener() {
    _authService.addListener(() {
      if (_authService.isAuthenticated) {
        login();
        _userProvider.loadUserData();
      } else {
        _settings.isLoggedIn = false;
        _userProvider.clearUserData();
        _saveSettings();
        notifyListeners();
      }
    });
  }

  Future<void> _loadSettings() async {
    if (_box.isEmpty) {
      _settings = AppSettings.initial();
      await _saveSettings();
    } else {
      _settings = _box.get('settings');
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _box.put('settings', _settings);
  }

  Future<void> login() async {
    _settings.isLoggedIn = true;
    await _saveSettings();
    
    // Save to SharedPreferences as well
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _authService.signOut();

      // Clear Hive storage
      _settings.isLoggedIn = false;
      await _saveSettings();
      await _box.delete('userData');
      await _box.clear();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset settings to initial state
      _settings = AppSettings.initial();
      await _saveSettings();

      // Clear user data
      _userProvider.clearUserData();

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      throw e;
    }
  }

  void setMode(AppMode mode) {
    _settings.mode = mode;
    _saveSettings();
    notifyListeners();
  }
}
