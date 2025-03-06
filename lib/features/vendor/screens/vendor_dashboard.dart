import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String currentSide = 'vendor';
  bool isProfileComplete = false;
  bool isOnline = false; // 🔴 Vendor ki online/offline status

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
    _listenToProfileUpdates();
    _fetchOnlineStatus();
  }

  /// **Firebase se vendor ka online status check karna**
  void _fetchOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          bool status = doc.data()?['isOnline'] ?? false;
          setState(() {
            isOnline = status;
          });
        }
      });
    }
  }

  /// **Vendor ka status Firebase me update karna**
  void _toggleOnlineStatus(bool status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .update({'isOnline': status});
    }
  }

  /// **Profile Updates Firebase se listen karna**
  void _listenToProfileUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          bool updatedProfileStatus = doc.data()?['isProfileComplete'] ?? false;
          setState(() {
            isProfileComplete = updatedProfileStatus;
          });
        }
      });
    }
  }

  Future<void> _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'vendor';
    });
  }

  Future<void> _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('side', side);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text('Vendor Dashboard'),
        actions: [
          Row(
            children: [
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isOnline,
                onChanged: (bool value) {
                  setState(() {
                    isOnline = value;
                  });
                  _toggleOnlineStatus(value);
                },
              ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Vendor Options',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Vendor Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/Vendor_profile');
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
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      SizedBox(height: 15),
                      Text(
                        'Transforming the way you do business',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      _buildBenefitRow('📈', 'Grow Your Business Effortlessly'),
                      SizedBox(height: 10),
                      _buildBenefitRow('📅', 'Efficiently Manage Your Bookings'),
                      SizedBox(height: 10),
                      _buildBenefitRow('⚡', 'Deliver Services Seamlessly'),
                      SizedBox(height: 10),
                      _buildBenefitRow('💼', 'Create a Professional Profile'),
                      SizedBox(height: 10),
                      _buildBenefitRow('💬', 'Stay Connected with Clients'),
                      SizedBox(height: 20),
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
                      SizedBox(height: 15),

                      /// ✅ **Button only if profile is NOT complete**
                      if (!isProfileComplete)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/Vendor_profile');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            backgroundColor: Colors.blue[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Update your Profile",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 **_buildBenefitRow function ab class ke andar hai**
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
}
