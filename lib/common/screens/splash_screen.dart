import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:home_services/common/providers/auth_service.dart';
import 'package:home_services/common/providers/main_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.delayed to ensure the widget is fully built
    Future.delayed(Duration.zero, () {
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final mainController = Provider.of<MainController>(context, listen: false);
      
      final prefs = await SharedPreferences.getInstance();
      bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      // Check all three conditions
      if (authService.currentUser != null && 
          isLoggedIn && 
          mainController.settings.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/client_dashboard');
      } else {
        // Clear all stored states if any condition fails
        await mainController.logout();
        
        if (!isOnboarded) {
          Navigator.pushReplacementNamed(context, '/onboarding1');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error in splash screen: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/Spalish.json',
                  width: screenSize.width * 0.7,
                  height: screenSize.width * 0.7,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
