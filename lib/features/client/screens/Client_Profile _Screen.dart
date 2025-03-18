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
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? selectedCity;
  String? clientDocId;
  bool isEditing = false;
  String? selectedGender;
  DateTime? dateOfBirth;
  String? profileImageUrl;
  bool isLoading = true;

  final List<String> cities = ["Lahore", "Multan"];
  final List<String> genderOptions = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('clients')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first.data();
          setState(() {
            clientDocId = snapshot.docs.first.id;
            nameController.text = userData['name'] ?? '';
            phoneController.text = userData['phone'] ?? '';
            emailController.text = userData['email'] ?? user.email ?? '';
            addressController.text = userData['address'] ?? '';
            selectedCity = userData['city'];
            selectedGender = userData['gender'];
            profileImageUrl = userData['profileImage'];
            dateOfBirth = userData['dateOfBirth']?.toDate();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final profileData = {
        'userId': user.uid,
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'address': addressController.text,
        'city': selectedCity,
        'gender': selectedGender,
        'dateOfBirth': dateOfBirth,
        'profileImage': profileImageUrl,
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (clientDocId != null) {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(clientDocId)
            .update(profileData);
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('clients')
            .add(profileData);
        clientDocId = docRef.id;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() => isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool isEditable) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: isEditable ? Colors.black87 : Colors.black54,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            color: Colors.blue[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: "Enter your ${label.toLowerCase()}",
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              getIconForField(label),
              color: isEditable ? Colors.blue[700] : Colors.grey[400],
              size: 22,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          filled: true,
          fillColor: isEditable ? Colors.white : Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: TextStyle(
            color: Colors.red[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              isEditable ? Icons.edit : Icons.lock_outline,
              color: isEditable ? Colors.blue[700] : Colors.grey[400],
              size: 20,
            ),
          ),
        ),
        validator: (value) =>
            value!.isEmpty ? "Please enter your ${label.toLowerCase()}" : null,
        readOnly: !isEditable,
      ),
    );
  }

  IconData getIconForField(String label) {
    switch (label.toLowerCase()) {
      case 'full name':
        return Icons.person_outline;
      case 'email':
        return Icons.email_outlined;
      case 'phone number':
        return Icons.phone_outlined;
      default:
        return Icons.text_fields;
    }
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue[700]),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(
              color: Colors.blue[800],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.location_city,
                color: Colors.blue[700],
                size: 22,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue, width: 1.5),
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            errorStyle: TextStyle(
              color: Colors.red[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          isExpanded: true,
          itemHeight: 50,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Container(
                      height: 100, // Set height here

                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedValue == item
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: selectedValue == item
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (selectedValue == item)
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue[700],
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          onChanged: isEditing ? onChanged : null,
          validator: (value) => value == null ? "Please select a city" : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          "Client Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 90, color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  buildTextField("Full Name", nameController, isEditing),
                  SizedBox(height: 16),
                  buildTextField(
                    "Email",
                    emailController,
                    isEditing,
                  ),
                  SizedBox(height: 16),
                  buildTextField("Phone Number", phoneController, isEditing),
                  SizedBox(height: 16),
                  buildTextField("Address", addressController, isEditing),
                  SizedBox(height: 16),
                  buildDropdown("Select City", cities, selectedCity,
                      (value) => setState(() => selectedCity = value)),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: isEditing
                          ? _updateProfile
                          : () => setState(() => isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isEditing ? Icons.save : Icons.edit,
                              color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            isEditing ? "Save Profile" : "Edit Profile",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
