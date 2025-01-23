import 'package:flutter/material.dart';

class VendorProfileViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Profile Details',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ListTile(
              leading: Icon(Icons.person, color: Colors.orange),
              title: Text('Full Name'),
              subtitle: Text('Vendor Name'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.orange),
              title: Text('Email'),
              subtitle: Text('vendor@example.com'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.orange),
              title: Text('Phone Number'),
              subtitle: Text('+123 456 789'),
            ),
            Divider(),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle edit profile
                },
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
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
