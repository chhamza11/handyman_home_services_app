// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkUserStatus();
//   }
//
//   Future<void> _checkUserStatus() async {
//     await Future.delayed(Duration(seconds: 2)); // Simulate splash screen delay
//     User? user = FirebaseAuth.instance.currentUser;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
//
//     if (user != null) {
//       Navigator.pushReplacementNamed(context, '/client_dashboard');
//     } else {
//       if (!isOnboarded) {
//         Navigator.pushReplacementNamed(context, '/onboarding1');
//       } else {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue, Colors.purple],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.flutter_dash,
//                   size: screenSize.width * 0.2,
//                   color: Colors.white,
//                 ),
//                 SizedBox(height: screenSize.height * 0.02),
//                 SizedBox(
//                   width: screenSize.width * 0.1,
//                   height: screenSize.width * 0.1,
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 ),
//                 SizedBox(height: screenSize.height * 0.02),
//                 Text(
//                   'Loading...',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: screenSize.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate splash screen delay
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/client_dashboard');
    } else {
      if (!isOnboarded) {
        Navigator.pushReplacementNamed(context, '/onboarding1');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(

            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Replace Icon & Loader with Lottie Animation
                Lottie.asset(
                  'assets/animations/Spalish.json', // Path to your Lottie file
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
