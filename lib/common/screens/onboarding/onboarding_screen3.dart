import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Get Started!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Set onboarding status to true
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isOnboarded', true);

                // Navigate to the login screen
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
