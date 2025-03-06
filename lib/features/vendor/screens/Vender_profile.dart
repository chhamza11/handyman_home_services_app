import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? selectedCity;
  String? selectedMainCategory;
  List<String> selectedSubCategories = [];
  String? vendorDocId;
  bool isEditing = false;

  final List<String> cities = ["Lahore", "Multan"];

  final Map<String, List<String>> categories = {
    "Home Labour Services": ["Garden Care", "House Cleaning", "Clothe Cleaning", "Cooking"],
    "Indoor Catering": ["Birthday Party", "Anniversary Celebration", "Corporate Event", "Wedding Catering"],
    "Paint Services": ["Interior & Exterior Painting", "Wood & Metal Painting", "Decorative & Texture Painting", "Door & Gate Painting", "Industrial Painting"],
    "Furniture Repair Services": ["Office Furniture Repair", "Home Furniture Repair", "Sofa & Upholstery Repair", "Doors & Fixtures Repair"],
    "Solar Services": ["Solar Installation", "Solar Cleaning"],
  };

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
            .collection('vendors')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          var data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            setState(() {
              vendorDocId = doc.id;
              nameController.text = data['name'] ?? '';
              phoneController.text = data['phone'] ?? '';
              selectedCity = data['city'] ?? '';
              selectedMainCategory = data['mainCategory'] ?? '';
              selectedSubCategories = List<String>.from(data['subCategories'] ?? []);
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching vendor profile: $e");
      }
    }
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          CollectionReference vendors = FirebaseFirestore.instance.collection('vendors');

          Map<String, dynamic> profileData = {
            'name': nameController.text,
            'phone': phoneController.text,
            'city': selectedCity ?? '',
            'mainCategory': selectedMainCategory ?? '',
            'subCategories': selectedSubCategories,
            'updatedAt': FieldValue.serverTimestamp(),
            'isProfileComplete': true,
          };

          if (vendorDocId != null) {
            await vendors.doc(vendorDocId).update(profileData);
          } else {
            DocumentReference newVendorDoc = vendors.doc();
            vendorDocId = newVendorDoc.id;
            profileData['id'] = vendorDocId;
            profileData['email'] = user.email;
            profileData['createdAt'] = FieldValue.serverTimestamp();
            await newVendorDoc.set(profileData);
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

  Widget buildSubCategories() {
    if (selectedMainCategory == null) return SizedBox();

    // Agar edit mode on hai to sab options dikhao, warna sirf selected
    bool showAllOptions = isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories[selectedMainCategory]!.where((sub) {
        return showAllOptions || selectedSubCategories.contains(sub);
      }).map((sub) {
        return CheckboxListTile(
          title: Text(sub, style: TextStyle(color: Colors.black87)),
          activeColor: Colors.blueAccent,
          value: selectedSubCategories.contains(sub),
          onChanged: isEditing
              ? (bool? value) {
            setState(() {
              if (value == true) {
                selectedSubCategories.add(sub);
              } else {
                selectedSubCategories.remove(sub);
              }
            });
          }
              : null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Vendor Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                buildTextField("Full Name", nameController, isEditing),
                SizedBox(height: 10),
                buildTextField("Email", TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? ''), false),
                SizedBox(height: 10),
                buildTextField("Phone Number", phoneController, isEditing),
                SizedBox(height: 10),
                buildDropdown("Select City", cities, selectedCity, (value) => setState(() => selectedCity = value)),
                SizedBox(height: 10),
                buildDropdown("Select Main Category", categories.keys.toList(), selectedMainCategory, (value) {
                  setState(() {
                    selectedMainCategory = value;
                    selectedSubCategories.clear();
                  });
                }),
                SizedBox(height: 10),
                if (selectedMainCategory != null) buildSubCategories(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: isEditing ? saveProfile : () => setState(() => isEditing = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30), // Extra horizontal padding for better UI
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 5,
                    ),
                    child: Text(
                      isEditing ? "Save" : "Update Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, bool isEditable) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      readOnly: !isEditable,
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: isEditing ? onChanged : null,
      validator: (value) => value == null ? "Select $label" : null,
    );
  }
}
