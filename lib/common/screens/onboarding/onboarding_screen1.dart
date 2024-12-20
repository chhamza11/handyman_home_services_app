import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to the App!'),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  'Discover amazing services at your fingertips! Our app connects you with top service providers to meet all your needs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/onboarding_image.png',
                height: screenHeight * 0.25,
                fit: BoxFit.cover,
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/onboarding2');
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
