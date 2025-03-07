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
    "Home Labour Services": [
      "Garden Care",
      "House Cleaning",
      "Clothe Cleaning",
      "Cooking"
    ],
    "Indoor Catering": [
      "Birthday Party",
      "Anniversary Celebration",
      "Corporate Event",
      "Wedding Catering"
    ],
    "Paint Services": [
      "Interior & Exterior Painting",
      "Wood & Metal Painting",
      "Decorative & Texture Painting",
      "Door & Gate Painting",
      "Industrial Painting"
    ],
    "Furniture Repair Services": [
      "Office Furniture Repair",
      "Home Furniture Repair",
      "Sofa & Upholstery Repair",
      "Doors & Fixtures Repair"
    ],
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
              selectedSubCategories =
                  List<String>.from(data['subCategories'] ?? []);
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
          CollectionReference vendors =
              FirebaseFirestore.instance.collection('vendors');

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

    bool showAllOptions = isEditing;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              "Sub Categories",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...categories[selectedMainCategory]!.where((sub) {
            return showAllOptions || selectedSubCategories.contains(sub);
          }).map((sub) {
            return Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.blue[200],
              ),
              child: CheckboxListTile(
                title: Text(
                  sub,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                activeColor: Colors.blue[700],
                checkColor: Colors.white,
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
                dense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          "Vendor Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      TextEditingController(
                          text: FirebaseAuth.instance.currentUser?.email ?? ''),
                      false),
                  SizedBox(height: 16),
                  buildTextField("Phone Number", phoneController, isEditing),
                  SizedBox(height: 16),
                  buildDropdown("Select City", cities, selectedCity,
                      (value) => setState(() => selectedCity = value)),
                  SizedBox(height: 16),
                  buildDropdown("Select Main Category",
                      categories.keys.toList(), selectedMainCategory, (value) {
                    setState(() {
                      selectedMainCategory = value;
                      selectedSubCategories.clear();
                    });
                  }),
                  SizedBox(height: 16),
                  if (selectedMainCategory != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: buildSubCategories(),
                    ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: isEditing
                          ? saveProfile
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                label.contains("City") ? Icons.location_city : Icons.category,
                color: Colors.blue[700],
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
                      height: 200,
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
                            label.contains("City")
                                ? Icons.location_on_outlined
                                : Icons.work_outline,
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
          validator: (value) =>
              value == null ? "Please select a ${label.toLowerCase()}" : null,
        ),
      ),
    );
  }
}
