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
      appBar: AppBar(backgroundColor: Colors.brown, title: Text('Vendor Dashboard')),
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)], // Aqua to light green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Title
                Text(
                  'Welcome to Our Service App!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Subtitle
                Text(
                  'Transforming the way you do business',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Benefits
                _buildBenefitRow('📈', 'Grow Your Business Effortlessly'),
                SizedBox(height: 15),
                _buildBenefitRow('📅', 'Efficiently Manage Your Bookings'),
                SizedBox(height: 15),
                _buildBenefitRow('⚡', 'Deliver Services Seamlessly'),
                SizedBox(height: 15),
                _buildBenefitRow('💼', 'Create a Professional Profile'),
                SizedBox(height: 15),
                _buildBenefitRow('💬', 'Stay Connected with Clients'),
                SizedBox(height: 30),

                // Closing Note
                Text(
                  'Join us today and take your business to the next level!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
Widget _buildBenefitRow(String icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        icon,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ),
    ],
  );
}
