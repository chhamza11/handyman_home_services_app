import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDashboardScreen extends StatefulWidget {
  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String currentSide = 'client'; // Default side is Client
  int _selectedIndex = 0; // Track the selected index in the BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
  }

  // Load the saved side preference (Client or Vendor)
  Future<void> _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'client'; // Default to client
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

  // Function to handle Bottom Navigation Bar item selection
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // Profile tab selected
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName'); // Check if profile exists

      if (userName != null && userName.isNotEmpty) {
        // If profile exists, navigate to the profile screen (Edit Profile)
        Navigator.pushNamed(context, '/client_profile');
      } else {
        // If profile doesn't exist, navigate to create a new profile screen
        Navigator.pushNamed(context, '/create_profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
              onTap: () async {
                await _saveSidePreference('vendor');
                Navigator.of(context).pop(); // Close drawer
                Navigator.pushReplacementNamed(context, '/vendor_dashboard');
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
        child: Text(
          'Client Side Content',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      // Custom Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected item
        backgroundColor: Colors.white,
        elevation: 10, // Adds shadow for a more elegant look
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
