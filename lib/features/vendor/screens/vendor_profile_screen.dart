import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String selectedService = 'Cleaning';

  final List<String> services = ['Cleaning', 'Plumber', 'Electrician', 'Painter', 'Carpenter'];

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Save vendor profile to Firestore
        await _firestore.collection('vendors').doc(user.uid).set({
          'name': nameController.text,
          'phone': phoneController.text,
          'service': selectedService,
          'password': passwordController.text,
        });

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/vendor_dashboard');
      } catch (e) {
        print("Error saving profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Vendor Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: selectedService,
              onChanged: (String? newValue) {
                setState(() {
                  selectedService = newValue!;
                });
              },
              items: services.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
