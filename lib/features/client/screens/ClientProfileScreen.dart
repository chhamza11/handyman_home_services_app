import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  User? user;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Fetch the current logged-in user's UID
  _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user!.uid;
      await _loadProfile();
    }
  }

  // Load profile from Firestore if it exists
  _loadProfile() async {
    FirebaseFirestore.instance.collection('profiles').doc(userId).get().then((doc) {
      if (doc.exists) {
        _nameController.text = doc['name'];
        _phoneController.text = doc['phone'];
        _areaController.text = doc['area'];
        _addressController.text = doc['address'];
      }
    });
  }

  // Save profile data to Firestore
  _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('profiles').doc(userId).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'area': _areaController.text,
        'address': _addressController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));
        Navigator.pushReplacementNamed(context, '/client_dashboard');
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Area'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your area';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
