import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for Firebase
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'common/screens/login_screen.dart';
import 'common/screens/onboarding/onboarding_screen1.dart';
import 'common/screens/onboarding/onboarding_screen2.dart';
import 'common/screens/onboarding/onboarding_screen3.dart';
import 'common/screens/signup_screen.dart';
import 'common/screens/splash_screen.dart';
import 'features/client/screens/ClientProfileScreen.dart';
import 'features/client/screens/cleaning/Venders.dart';
import 'features/client/screens/cleaning/cleaning_service_screen.dart';
import 'features/client/screens/client_dashboard.dart';
import 'features/vendor/screens/VendorProfileScreen.dart';
import 'features/vendor/screens/vendor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized

  // Load the initial route dynamically based on SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final lastSide = prefs.getString('side') ?? 'client'; // Default to client side

  runApp(MyApp(initialRoute: lastSide == 'client' ? '/client_dashboard' : '/vendor_dashboard'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute, // Set the initial route dynamically
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding1': (context) => OnboardingScreen1(),
        '/onboarding2': (context) => OnboardingScreen2(),
        '/onboarding3': (context) => OnboardingScreen3(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/client_dashboard': (context) => ClientDashboardScreen(),
        '/vendor_dashboard': (context) => VendorDashboardScreen(),
        '/client_profile': (context) => ClientProfileScreen(),
        '/vendor_profile': (context) => VendorProfileScreen(),

        '/cleaning_service': (context) => CleaningServiceScreen(),
        '/Venders': (context) =>Venders(),
        // Cleaning service screen route
      },
    );
  }
}
