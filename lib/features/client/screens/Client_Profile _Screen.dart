import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? selectedCity;
  String? clientDocId;
  bool isEditing = false;

  final List<String> cities = ["Lahore", "Multan"];

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('clients')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          var data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            setState(() {
              clientDocId = doc.id;
              nameController.text = data['name'] ?? '';
              phoneController.text = data['phone'] ?? '';
              selectedCity = data['city'] ?? '';
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching client profile: $e");
      }
    }
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          CollectionReference clients =
          FirebaseFirestore.instance.collection('clients');

          Map<String, dynamic> profileData = {
            'name': nameController.text,
            'phone': phoneController.text,
            'city': selectedCity ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
            'isProfileComplete': true,
          };

          if (clientDocId != null) {
            await clients.doc(clientDocId).update(profileData);
          } else {
            DocumentReference newClientDoc = clients.doc();
            clientDocId = newClientDoc.id;
            profileData['id'] = clientDocId;
            profileData['email'] = user.email;
            profileData['createdAt'] = FieldValue.serverTimestamp();
            await newClientDoc.set(profileData);
          }

          setState(() {
            isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Profile Updated Successfully!"),
            backgroundColor: Colors.green,
          ));
        } catch (e) {
          debugPrint("Error saving profile: $e");
        }
      }
    }
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool isEnabled) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      validator: (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildDropdown(
      String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: isEditing ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Client Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTextField("Full Name", nameController, isEditing),
                SizedBox(height: 16),
                buildTextField(
                  "Email",
                  TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? ''),
                  false,
                ),
                SizedBox(height: 16),
                buildTextField("Phone Number", phoneController, isEditing),
                SizedBox(height: 16),
                buildDropdown("Select City", cities, selectedCity,
                        (value) => setState(() => selectedCity = value)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isEditing ? saveProfile : () => setState(() => isEditing = true),
                  child: Text(isEditing ? "Save Profile" : "Edit Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
