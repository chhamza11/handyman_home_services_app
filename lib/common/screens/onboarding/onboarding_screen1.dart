import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/onbording/01.svg',
                semanticsLabel: 'Onboarding Image',
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/onboarding2');
                  },
                  backgroundColor: Color(0xFFEDB232),
                  child: Icon(
                    Icons.arrow_forward,
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
