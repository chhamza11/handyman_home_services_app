import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedCity;
  bool isEditing = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = auth.currentUser;

    // Debugging Logs
    print("User ID: ${user?.uid}");
    print("User Email from FirebaseAuth: ${user?.email}");
    print("User Display Name: ${user?.displayName}");

    if (user != null) {
      DocumentSnapshot userDoc =
      await firestore.collection('clients').doc(user.uid).get();

      print("Firestore Data: ${userDoc.data()}");

      setState(() {
        nameController.text = userDoc.exists
            ? (userDoc['name'] ?? user.displayName ?? '')
            : (user.displayName ?? '');

        // Email Debugging
        if (user.email != null) {
          emailController.text = user.email!;
          print("Using FirebaseAuth Email: ${user.email!}");
        } else if (userDoc.exists && userDoc['email'] != null) {
          emailController.text = userDoc['email'];
          print("Using Firestore Email: ${userDoc['email']}");
        } else {
          emailController.text = "Email not found!";
          print("Email is NULL in both FirebaseAuth and Firestore");
        }

        selectedCity = userDoc.exists ? userDoc['city'] ?? null : null;
      });
    } else {
      print("No user logged in!");
    }
  }

  Future<void> updateProfile() async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        await firestore.collection('clients').doc(user.uid).set({
          'name': nameController.text,
          'email': emailController.text,
          'city': selectedCity,
        }, SetOptions(merge: true));

        setState(() {
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text('Client Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
              enabled: isEditing,
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCity,
              items: ['Lahore', 'Multan'].map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: isEditing
                  ? (value) {
                setState(() {
                  selectedCity = value;
                });
              }
                  : null,
              decoration: InputDecoration(labelText: 'Select City'),
            ),
            SizedBox(height: 20),
            isEditing
                ? ElevatedButton(
              onPressed: updateProfile,
              child: Text('Save'),
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
