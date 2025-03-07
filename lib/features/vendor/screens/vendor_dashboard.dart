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
  String vendorName = 'Guest';

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
          setState(() {
            isProfileComplete = doc.data()?['isProfileComplete'] ?? false;
            vendorName = doc.data()?['name']?.trim() ?? 'Guest';
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
        backgroundColor: Colors.blue[400],
        elevation: 0,
        title: Text(
          'Vendor Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Switch(
                  value: isOnline,
                  onChanged: (bool value) {
                    setState(() {
                      isOnline = value;
                    });
                    _toggleOnlineStatus(value);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green[300],
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                height: 230,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                isProfileComplete
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: 50,
                                color: Colors.blue[600],
                              ),
                            ),
                          ),
                          if (!isProfileComplete)
                            Positioned(
                              right: 0,
                              bottom: 10,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Welcome ${vendorName}!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!isProfileComplete)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Complete your profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(height: 5),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                            Text(
                              isOnline ? 'Active Now' : 'Offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        title: 'Vendor Profile',
                        subtitle: 'Manage your profile details',
                        onTap: () =>
                            Navigator.pushNamed(context, '/Vendor_profile'),
                      ),
                      Divider(color: Colors.grey[200], thickness: 1),
                      _buildDrawerItem(
                        icon: Icons.swap_horiz_outlined,
                        title: 'Switch to Client Side',
                        subtitle: 'View as a client',
                        onTap: () async {
                          await _saveSidePreference('client');
                          Navigator.pushReplacementNamed(
                              context, '/client_dashboard');
                        },
                      ),
                      Divider(color: Colors.grey[200], thickness: 1),
                      _buildDrawerItem(
                        icon: Icons.logout_outlined,
                        title: 'Logout',
                        subtitle: 'Sign out from your account',
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  'App Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeaderSection(),
                        SizedBox(height: 30),
                        _buildBenefitsSection(),
                        SizedBox(height: 30),
                        if (!isProfileComplete) _buildProfileButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.blue[700],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blue[900],
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: Colors.blue.withOpacity(0.05),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome to Our Service App!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
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
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBenefitRow('📈', 'Grow Your Business Effortlessly'),
          SizedBox(height: 15),
          _buildBenefitRow('📅', 'Efficiently Manage Your Bookings'),
          SizedBox(height: 15),
          _buildBenefitRow('⚡', 'Deliver Services Seamlessly'),
          SizedBox(height: 15),
          _buildBenefitRow('💼', 'Create a Professional Profile'),
          SizedBox(height: 15),
          _buildBenefitRow('💬', 'Stay Connected with Clients'),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/Vendor_profile');
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: Colors.blue[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Complete Your Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
