import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _idCardController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _serviceController = TextEditingController();

  String? selectedCountry;
  String? selectedRegion;
  String? selectedCity;
  List<String> countries = ['Pakistan', 'Afghanistan']; // Example countries
  Map<String, List<String>> regions = {
    'Pakistan': ['Punjab', 'Sindh', 'Khyber Pakhtunkhwa'],
    'Afghanistan': ['Kabul', 'Herat', 'Mazar-i-Sharif'],
  };
  Map<String, List<String>> cities = {
    'Punjab': ['Lahore', 'Islamabad', 'Multan'],
    'Sindh': ['Karachi', 'Hyderabad'],
    'Khyber Pakhtunkhwa': ['Peshawar', 'Abbottabad'],
    'Kabul': ['Kabul City'],
    'Herat': ['Herat City'],
    'Mazar-i-Sharif': ['Mazar City'],
  };

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
    FirebaseFirestore.instance.collection('vendors').doc(userId).get().then((doc) {
      if (doc.exists) {
        _nameController.text = doc['name'];
        _phoneController.text = doc['phone'];
        _idCardController.text = doc['idCard'];
        _addressController.text = doc['address'];
        _serviceController.text = doc['service'];
        setState(() {
          selectedCountry = doc['country'];
          selectedRegion = doc['region'];
          selectedCity = doc['city'];
        });
      }
    });
  }

  // Save vendor profile data to Firestore
  _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('vendors').doc(userId).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'idCard': _idCardController.text,
        'country': selectedCountry,
        'region': selectedRegion,
        'city': selectedCity,
        'address': _addressController.text,
        'service': _serviceController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Profile'),
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
                controller: _idCardController,
                decoration: InputDecoration(labelText: 'ID Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID Card number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(labelText: 'Country'),
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedRegion = null;
                    selectedCity = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a country';
                  }
                  return null;
                },
              ),
              if (selectedCountry != null)
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: InputDecoration(labelText: 'Region'),
                  items: regions[selectedCountry]!.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value;
                      selectedCity = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a region';
                    }
                    return null;
                  },
                ),
              if (selectedRegion != null)
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(labelText: 'City'),
                  items: cities[selectedRegion]!.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address (within city)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _serviceController,
                decoration: InputDecoration(labelText: 'Service Provided'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service you provide';
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
