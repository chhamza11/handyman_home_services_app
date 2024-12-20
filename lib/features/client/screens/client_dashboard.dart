import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDashboardScreen extends StatefulWidget {
  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String currentSide = 'client'; // Default side is Client

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
  }

  // Load the saved side preference
  _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'client'; // Default to client
    });
  }

  // Save the selected side preference
  _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('side', side); // Save the side preference
  }

  // Function to handle logout
  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('side'); // Optionally clear the saved side preference
    Navigator.pushReplacementNamed(context, 'login'); // Redirect to Login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Client Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Vendor Side'),
              onTap: () {
                setState(() {
                  currentSide = 'vendor'; // Switch to vendor side
                });
                _saveSidePreference('vendor'); // Save the preference
                Navigator.of(context).pop(); // Close the drawer
                Navigator.pushReplacementNamed(context, 'vendor_dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout, // Logout functionality
            ),
            // Add other menu items here...
          ],
        ),
      ),
      body: Center(
        child: Text('Client Side Content'),
      ),
    );
  }
}
