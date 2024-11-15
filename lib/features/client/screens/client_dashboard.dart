import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'MY Account',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Switch to Vendor Side'),
              leading: const Icon(Icons.switch_account),
              onTap: () {
                // Navigate to Vendor Dashboard
                Navigator.pushReplacementNamed(context, '/vendorDashboard');
              },
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isOnboarded', false);
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/splash');
              },
            ),

          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to Client Dashboard!'),
      ),
    );
  }
}
