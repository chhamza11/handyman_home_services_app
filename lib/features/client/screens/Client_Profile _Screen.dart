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
      String label, TextEditingController controller, bool isEditable) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2B5F56).withOpacity(0.08),
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
            color: Color(0xFF2B5F56),
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
              color: isEditable ? Color(0xFF2B5F56) : Colors.grey[400],
              size: 22,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF2B5F56).withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF2B5F56), width: 1.5),
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
              color: isEditable ?  Color(0xFF2B5F56) : Colors.grey[400],
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
            color: Color(0xFF2B5F56).withOpacity(0.08),
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
          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2B5F56)),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(
              color: Color(0xFF2B5F56),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.location_city,
                color: Color(0xFF2B5F56),
                size: 22,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF2B5F56).withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF2B5F56), width: 1.5),
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
                    ? Color(0xFF2B5F56).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Color(0xFF2B5F56),
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
                      color: Color(0xFF2B5F56),
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
    return Scaffold(
      backgroundColor: Color(0xFF2B5F56),
      appBar: AppBar(
        title: Text(
          "Client Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Color(0xFF2B5F56),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B5F56)!, Colors.white],
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
                              colors: [Color(0xFF2B5F56), Colors.black],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 90, color: Color(0xFF2B5F56)),
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
                    TextEditingController(
                        text: FirebaseAuth.instance.currentUser?.email ?? ''),
                    false,
                  ),
                  SizedBox(height: 16),
                  buildTextField("Phone Number", phoneController, isEditing),
                  SizedBox(height: 16),
                  buildDropdown("Select City", cities, selectedCity,
                          (value) => setState(() => selectedCity = value)),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: isEditing
                          ? saveProfile
                          : () => setState(() => isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEDB232),
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
