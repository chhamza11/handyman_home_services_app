import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/onbording/03.svg', // Make sure to add your third SVG file
                semanticsLabel: 'Onboarding Image 3',
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () async {
                    // Set onboarding status to true
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isOnboarded', true);

                    // Navigate to the login screen
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  backgroundColor: Color(0xFFEDB232),
                  child: Icon(
                    Icons.check, // Using check icon for the final screen
                    color: Color(0xFF2B5F56),
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
