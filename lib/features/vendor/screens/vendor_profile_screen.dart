import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  bool _isSaving = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  String _selectedCity = '';
  String _selectedMainCategory = '';
  List<String> _selectedSubCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController),
            TextField(controller: _phoneController),
            TextField(controller: _experienceController),
            // Add other fields and widgets here
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? CircularProgressIndicator()
                  : Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      // Show loading indicator
      setState(() {
        _isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Create the vendor data map
      Map<String, dynamic> vendorData = {
        'name': _nameController.text.trim(),
        'email': user.email,
        'phone': _phoneController.text.trim(),
        'city': _selectedCity,
        'mainCategory': _selectedMainCategory,
        'subCategories': _selectedSubCategories.toList(),
        'experience': _experienceController.text.trim(),
        'isProfileComplete': true,
        'isAvailable': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update the vendor document using the user's UID as the document ID
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)  // Use the authenticated user's UID
          .set(vendorData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context); // Or navigate to another screen
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
