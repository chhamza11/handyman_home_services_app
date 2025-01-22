import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/client/screens/Venders.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String currentSide = 'vendor';
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
    _loadOnlineStatus();
  }

  // Load the saved side preference (Client or Vendor)
  Future<void> _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'vendor';
    });
  }

  // Load online status from Firebase
  Future<void> _loadOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('vendors').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          isOnline = doc['isOnline'] ?? false;
        });
      }
    }
  }

  // Save online status to Firebase
  Future<void> _toggleOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('vendors').doc(user.uid).update({
        'isOnline': !isOnline,
      }).then((value) {
        setState(() {
          isOnline = !isOnline;
        });
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text('Vendor Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Vendor Options', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Vendor Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/vendor_profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Client Side'),
              onTap: () async {
                await _saveSidePreference('client');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Vendor!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleOnlineStatus,
              child: Text(isOnline ? 'Go Offline' : 'Go Online'),
            ),
            if (isOnline)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Venders(), // Displaying vendor's related services
                    ),
                  );
                },
                child: Text('View My Services'),
              ),
          ],
        ),
      ),
    );
  }

  // Save the side preference (Client or Vendor)
  Future<void> _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('side', side);
  }
}