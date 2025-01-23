import 'package:flutter/material.dart';

class VendorProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Portal',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.05,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome Message
            Text(
              'Welcome to the Vendor Portal!',
              style: TextStyle(
                fontSize: screenWidth * 0.06, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04), // Vertical spacing

            // Informative Text
            Text(
              'Easily manage your services, bookings, and profile all in one place.',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.06), // Vertical spacing

            // View Profile Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/vendor_profile_view'); // Navigate to Vendor Profile
              },
              child: Text(
                'View Profile',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.3, // Responsive width
                  vertical: screenHeight * 0.02, // Button height
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded button
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06), // Vertical spacing

            // Login & Sign Up Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Login Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vendor_login'); // Navigate to Vendor Login
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded button
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.05), // Horizontal spacing

                // Sign Up Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vendor_signup'); // Navigate to Vendor Sign Up
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded button
                      ),
                    ),
                  ),
                ),
              ],
            ),


            SizedBox(height: screenHeight * 0.03), // Additional vertical spacing

            // Footer Note
            Text(
              'Join us and take your business to the next level!',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
