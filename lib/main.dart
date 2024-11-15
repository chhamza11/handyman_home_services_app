import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for Firebase
import 'common/screens/login_screen.dart';
import 'common/screens/onboarding/onboarding_screen1.dart';
import 'common/screens/onboarding/onboarding_screen2.dart';
import 'common/screens/onboarding/onboarding_screen3.dart';
import 'common/screens/signup_screen.dart';
import 'common/screens/splash_screen.dart';
import 'features/client/screens/client_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding1': (context) => OnboardingScreen1(),
        '/onboarding2': (context) => OnboardingScreen2(),
        '/onboarding3': (context) => OnboardingScreen3(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/client_dashboard': (context) => ClientDashboardScreen(), // Add your dashboard screen here
      },
    );
  }
}
