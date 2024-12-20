import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String currentSide = "vendor"; // Default side is Vendor

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
  }

  _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'vendor'; // Default to vendor
    });
  }

  _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('side', side); // Save the side preference
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor Dashboard"),
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
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Client Side'),
              onTap: () {
                setState(() {
                  currentSide = 'client'; // Switch to client side
                });
                _saveSidePreference('client'); // Save the preference
                Navigator.of(context).pop(); // Close the drawer
                Navigator.pushReplacementNamed(context, '/client_dashboard');
              },
            ),
            // Add other menu items here...
          ],
        ),
      ),
      body: Center(
        child: Text("Vendor Side Content"),
      ),
    );
  }
}
