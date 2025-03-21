import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/vendor/screens/vendor_requests_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String currentSide = 'vendor';
  bool isProfileComplete = false;
  bool isOnline = false; // 🔴 Vendor ki online/offline status
  String vendorName = 'Guest';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
    _checkProfileStatus();
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
  void _checkProfileStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // First try to find by UID
        final docByUid = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(user.uid)
            .get();

        if (docByUid.exists) {
          setState(() {
            isProfileComplete = docByUid.data()?['isProfileComplete'] ?? false;
            vendorName = docByUid.data()?['name']?.trim() ?? 'Guest';
          });
          return;
        }

        // If not found by UID, try by email
        final queryByEmail = await FirebaseFirestore.instance
            .collection('vendors')
            .where('email', isEqualTo: user.email)
            .get();

        if (queryByEmail.docs.isNotEmpty) {
          final doc = queryByEmail.docs.first;
          setState(() {
            isProfileComplete = doc.data()['isProfileComplete'] ?? false;
            vendorName = doc.data()['name']?.trim() ?? 'Guest';
          });
        }
      } catch (e) {
        print('Error checking profile status: $e');
      }
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
        backgroundColor: Color(0xFF2B5F56),
        elevation: 0,
        title: Text(
          _currentIndex == 0 ? 'Vendor Dashboard' : 'Service Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontFamily: 'Montserrat',
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
      drawer: _buildDrawer(),
      body: isProfileComplete
          ? _buildMainContent()
          : _buildWelcomeScreen(),
      bottomNavigationBar: isProfileComplete ? _buildBottomNav() : null,
    );
  }

  Widget _buildMainContent() {
    return _currentIndex == 0 
        ? _buildDashboardContent() 
        : VendorRequestsScreen();
  }

  Widget _buildBottomNav() {

    return BottomNavigationBar(
      selectedItemColor: Color(0xFF2B5F56), // Active icon and label color
      unselectedItemColor: Colors.grey, // Optional: Unselected color
      // backgroundColor: Color(0xFF4C8479),
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',backgroundColor: Color(0xFF2B5F56),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Orders',

        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B5F56), Color(0xFF4C8479)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isProfileComplete ? Icons.person : Icons.person_outline,
                        size: 50,
                        color: Color(0xFF2B5F56),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome $vendorName!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
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
                              color: isOnline ? Color(0xFF2B5F56) : Color(0xFF4C8479),
                            ),
                          ),
                          Text(
                            isOnline ? 'Active Now' : 'Offline',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Vendor Profile',
                    subtitle: 'Manage your profile details',
                    onTap: () => Navigator.pushNamed(context, '/Vendor_profile'),
                  ),
                  if (isProfileComplete) _buildDrawerItem(
                    icon: Icons.assignment,
                    title: 'Service Requests',
                    subtitle: 'View and manage orders',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.swap_horiz_outlined,
                    title: 'Switch to Client Side',
                    subtitle: 'View as a client',
                    onTap: () async {
                      await _saveSidePreference('client');
                      Navigator.pushReplacementNamed(context, '/client_dashboard');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWelcomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B5F56)!, Color(0xFF4C8479)],
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
                      _buildProfileButton(),
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
          color: Color(0xFF2B5F56).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Color(0xFF2B5F56),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF2B5F56),
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
      hoverColor: Color(0xFF2B5F56).withOpacity(0.05),
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
              color: Color(0xFF2B5F56),
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
              color: Color(0xFF2B5F56),
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
        color: Color(0xFF2B5F56).withOpacity(0.05),
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
                color: Color(0xFF2B5F56),
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
          backgroundColor: Color(0xFF2B5F56),
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

  Widget _buildDashboardContent() {
    final vendorId = FirebaseAuth.instance.currentUser?.uid;
    if (vendorId == null) {
      return Center(child: Text('Error: Vendor not authenticated'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('vendorStats').doc(vendorId).snapshots(),
      builder: (context, statsSnapshot) {
        if (!statsSnapshot.hasData) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
        }

        final stats = statsSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        int totalOrders = stats['totalOrders'] ?? 0;
        int completedOrders = stats['completedOrders'] ?? 0;
        double totalEarnings = stats['totalEarnings'] ?? 0.0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('serviceRequests')
              .where('vendorId', isEqualTo: vendorId)
              .snapshots(),
          builder: (context, requestsSnapshot) {
            if (!requestsSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final requests = requestsSnapshot.data!.docs;
            int pendingOrders = requests.where((doc) => doc['status'] == 'assigned').length;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B5F56)),
                    ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Flexible(
                          child: _buildStatCard(
                            'Total Orders',
                            totalOrders.toString(),
                            Icons.assignment,
                            Color(0xFF2B5F56),
                          ),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: _buildStatCard(
                            'Completed',
                            completedOrders.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Pending',
                            pendingOrders.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                          SizedBox(width: 16),
                          _buildStatCard(
                            'Earnings',
                            'Rs.${totalEarnings.toStringAsFixed(2)}',
                            Icons.monetization_on,
                            Color(0xFFEDB232),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),
                    _buildRecentOrdersList(requests),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(List<QueryDocumentSnapshot> requests) {
    final recentRequests = requests
        .where((doc) => doc['status'] != 'rejected')
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B5F56),
          ),
        ),
        SizedBox(height: 16),
        ...recentRequests.map((request) {
          final data = request.data() as Map<String, dynamic>;
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: _getStatusIcon(data['status']),
              title: Text(data['subCategory'] ?? 'Unknown Service'),
              subtitle: Text('Client: ${data['clientName'] ?? 'Unknown'}'),
              trailing: Text(
                'Rs.${data['priceRange']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDB232),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'assigned':
        return Icon(Icons.pending_actions, color: Colors.orange);
      case 'accepted':
        return Icon(Icons.assignment_turned_in, color: Colors.orange);
      default:
        return Icon(Icons.assignment, color: Colors.grey);
    }
  }
}
