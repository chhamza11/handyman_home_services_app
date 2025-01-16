import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String currentSide = 'vendor'; // Default side is Vendor

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
  }

  // Load the saved side preference (Client or Vendor)
  Future<void> _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'vendor'; // Default to vendor
    });
  }

  // Save the side preference (Client or Vendor)
  Future<void> _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('side', side); // Save the side preference
  }

  // Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved preferences
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to Login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Vendor Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Vendor Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Vendor Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/vendor_profile'); // Navigate to profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Client Side'),
              onTap: () async {
                await _saveSidePreference('client'); // Save preference
                Navigator.of(context).pop(); // Close the drawer
                Navigator.pushReplacementNamed(context, '/client_dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Vendor Side Content'),
      ),
    );
  }
}
