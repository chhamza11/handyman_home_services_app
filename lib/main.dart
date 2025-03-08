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
import 'features/client/screens/Client_Profile _Screen.dart';
import 'features/client/screens/Venders.dart';
import 'features/client/screens/carpenter/carpenter_service.dart';
import 'features/client/screens/cleaning/cleaning_service_screen.dart';
import 'features/client/screens/cleaning/service_form_screen.dart';
import 'features/client/screens/client_dashboard.dart';
import 'features/client/screens/electrician/electrician_service.dart';
import 'features/client/screens/painter/painter_service.dart';
import 'features/client/screens/plumber/Plumber_Service_Screen.dart';
import 'features/vendor/screens/Vender_profile.dart';
import 'features/vendor/screens/vendor_dashboard.dart';
import 'features/vendor/screens/vendor_requests_screen.dart';




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
      initialRoute: '/splash', // Show splash screen first
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding1': (context) => OnboardingScreen1(),
        '/onboarding2': (context) => OnboardingScreen2(),
        '/onboarding3': (context) => OnboardingScreen3(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/client_dashboard': (context) => ClientDashboardScreen(),
        '/vendor_dashboard': (context) => VendorDashboardScreen(),
        '/vendor_requests': (context) => VendorRequestsScreen(),
        '/plumber_service': (context) => cateringServiceScreen(),
        '/electrician_service': (context) => ElectricianServiceScreen(),
        '/painter_service': (context) => PainterServiceScreen(),
        '/carpenter_service': (context) => CarpenterServiceScreen(),
        '/cleaning_service': (context) => CleaningServiceScreen(),
        '/Venders': (context) => Venders(),
        '/service_form_screen': (context) => ServiceFormScreen(),
        '/Vendor_profile': (context) => VendorProfileScreen(),
        '/Client_Profile_Screen': (context) =>  ClientProfileScreen(),

        // Ensure route to vendor profile is correct
      },
    );
  }
}
