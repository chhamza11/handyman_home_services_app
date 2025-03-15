import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for Firebase
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:hive_flutter/hive_flutter.dart'; // Change this import
import 'package:path_provider/path_provider.dart' as path_provider;
import 'common/screens/forgot_password_screen.dart';
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
import 'package:provider/provider.dart';
import 'package:home_services/common/providers/main_controller.dart';
import 'package:home_services/common/providers/auth_service.dart';
import 'package:home_services/common/providers/user_provider.dart';
import 'common/models/app_settings.dart';
import 'common/enums/global.dart';


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize path provider
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    
    // Initialize Hive
    await Hive.initFlutter(appDocumentDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppModeAdapter());
    }
    
    // Open Hive box
    final box = await Hive.openBox('appSettings');

    // Clear any existing login state on app start
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    // Create service instances
    final authService = AuthService();
    final userProvider = UserProvider();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => authService,
          ),
          ChangeNotifierProvider<UserProvider>(
            create: (_) => userProvider,
          ),
          ChangeNotifierProxyProvider2<AuthService, UserProvider, MainController>(
            create: (context) => MainController(
              authService: authService,
              userProvider: userProvider,
              box: box,
            ),
            update: (context, auth, user, previous) => 
              previous ?? MainController(
                authService: auth,
                userProvider: user,
                box: box,
              ),
          ),
        ],
        child: MyApp(initialRoute: '/splash'),
      ),
    );
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    // Handle initialization error appropriately
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',  // Default font
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,  // ExtraBold
          ),
          displayMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,  // Bold
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,  // SemiBold
          ),
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,  // Medium
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      initialRoute: initialRoute,
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
        '/forgot_password_screen': (context) =>  ForgotPasswordScreen(),
      },
    );
  }
}
