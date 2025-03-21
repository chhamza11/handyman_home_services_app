import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services/features/client/screens/available_vendors_screen.dart';
import 'package:home_services/features/client/services/service_request_handler.dart';
import 'package:home_services/features/client/screens/Client_Profile _Screen.dart';

class SolarServiceForm extends StatefulWidget {
  @override
  _SolarServiceFormState createState() => _SolarServiceFormState();
}

class _SolarServiceFormState extends State<SolarServiceForm> {
  // UI Color and Style constants matching Painter Service Form
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);
  final Color _cardBg = Colors.white;
  final Color _inputBg = Colors.white;

  String? selectedService;
  TextEditingController contactController = TextEditingController();
  TextEditingController specialRequestsController = TextEditingController();

  // Fields for solar services
  String? installationType;
  String? systemCapacity;
  String? panelType;
  bool batteryBackupRequired = false;
  String? inverterType;
  String? mountingType;
  String? cleaningType;
  String? cleaningMethod;
  String? panelAccessibility;

  final List<Map<String, dynamic>> serviceCategories = [
    {'name': 'Solar Installation', 'icon': Icons.solar_power},
    {'name': 'Solar Cleaning', 'icon': Icons.cleaning_services},
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double priceRange = 100.0; // Default price range

  final List<String> timeSlots = [
    '9:00-11:00 AM',
    '12:00-2:00 PM',
    '2:00-5:00 PM',
    '5:00-8:00 PM'
  ];
  List<String> _generateDateList() {
    List<String> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      dates.add(DateFormat('dd\nMMM').format(date));
    }
    return dates;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: _primaryDark,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'Service Request Form',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Service:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'),
                ),
                SizedBox(height: 10),
                _buildServiceCategorySelector(),
                SizedBox(height: 20),
                _buildDateSelector(),
                SizedBox(height: 20),
                _buildTimeSelector(),
                SizedBox(height: 20),
                _buildTextField(
                    contactController, 'Enter Mobile Number', Icons.phone,
                    keyboardType: TextInputType.phone),
                SizedBox(height: 20),
                if (selectedService != null) ...[
                  SizedBox(height: 20),
                  _buildCategorySpecificFields(selectedService!),
                ],
                SizedBox(height: 20),
                _buildPriceRangeSlider(),
                SizedBox(height: 20),
                _buildPaymentSection(),
                SizedBox(height: 20),
                _buildCancellationPolicy(),
                SizedBox(height: 20),
                _buildPriceDisplayAndOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: serviceCategories.map((service) {
          bool isSelected = selectedService == service['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedService = service['name'];
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? _primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _primaryDark.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(service['icon'],
                      color: isSelected ? Colors.white : _primaryDark),
                  SizedBox(height: 5),
                  Text(
                    service['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _primaryDark,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySpecificFields(String category) {
    switch (category) {
      case 'Solar Installation':
        return _buildSolarInstallationFields();
      case 'Solar Cleaning':
        return _buildSolarCleaningFields();
      default:
        return Container();
    }
  }

  Widget _buildSolarInstallationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Installation', installationType, [
          'Residential (Home) Solar Installation',
          'Commercial (Office/Shop) Solar Installation',
          'Industrial (Factory/Warehouse) Solar Installation',
        ], (value) => setState(() => installationType = value)),
        _buildDropdown('Solar System Capacity', systemCapacity, [
          'Small (1kW - 5kW)',
          'Medium (6kW - 15kW)',
          'Large (16kW and above)',
        ], (value) => setState(() => systemCapacity = value)),
        _buildDropdown('Type of Solar Panel', panelType, [
          'Monocrystalline',
          'Polycrystalline',
          'Thin-Film',
        ], (value) => setState(() => panelType = value)),
        SwitchListTile(
          title: Text('Battery Backup Required?'),
          value: batteryBackupRequired,
          onChanged: (value) {
            setState(() {
              batteryBackupRequired = value;
            });
          },
        ),
        _buildDropdown('Inverter Type', inverterType, [
          'Off-Grid',
          'On-Grid',
          'Hybrid',
        ], (value) => setState(() => inverterType = value)),
        _buildDropdown('Mounting Type', mountingType, [
          'Rooftop Installation',
          'Ground-Mounted Installation',
        ], (value) => setState(() => mountingType = value)),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note,
            maxLines: 3),
      ],
    );
  }

  Widget _buildSolarCleaningFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(specialRequestsController, 'Number of Panels to Clean',
            Icons.format_list_numbered,
            keyboardType: TextInputType.number),
        _buildDropdown('Type of Cleaning Required', cleaningType, [
          'Basic Dust Removal',
          'Deep Cleaning (Dirt, Bird Droppings, Pollutants)',
        ], (value) => setState(() => cleaningType = value)),
        _buildDropdown('Cleaning Method Preference', cleaningMethod, [
          'Water-Based Cleaning',
          'Dry Cleaning (For Dusty Areas)',
          'Chemical Cleaning (For Heavy Stains)',
        ], (value) => setState(() => cleaningMethod = value)),
        _buildDropdown('Accessibility of Panels', panelAccessibility, [
          'Easy Access (Single-Story)',
          'Hard-to-Reach (Multi-Story, High Roofs)',
        ], (value) => setState(() => panelAccessibility = value)),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note,
            maxLines: 3),
      ],
    );
  }

  Widget _buildDateSelector() {
    List<String> dates = _generateDateList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date & Time',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat')),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((date) {
              List<String> dateParts = date.split('\n');
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = DateFormat('dd\nMMM').parse(date);
                  });
                },
                child: Container(
                  width: 80,
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedDate == DateFormat('dd\nMMM').parse(date)
                        ? _primaryDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateParts[0],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedDate ==
                              DateFormat('dd\nMMM').parse(date)
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        dateParts[1],
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedDate ==
                              DateFormat('dd\nMMM').parse(date)
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeSlots.map((time) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ChoiceChip(
              label: Text(time),
              selected: selectedTime == _parseTimeSlot(time),
              onSelected: (selected) {
                setState(() {
                  selectedTime = selected ? _parseTimeSlot(time) : null;
                });
              },
              selectedColor: _primaryDark,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedTime == _parseTimeSlot(time)
                    ? Colors.white
                    : Colors.black,
                fontFamily: 'Montserrat',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  TimeOfDay _parseTimeSlot(String timeSlot) {
    switch (timeSlot) {
      case '9:00-11:00 AM':
        return TimeOfDay(hour: 9, minute: 0);
      case '12:00-2:00 PM':
        return TimeOfDay(hour: 12, minute: 0);
      case '2:00-5:00 PM':
        return TimeOfDay(hour: 14, minute: 0);
      case '5:00-8:00 PM':
        return TimeOfDay(hour: 17, minute: 0);
      default:
        return TimeOfDay.now();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: _darkText,
          fontFamily: 'Montserrat',
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _primaryDark,
            fontFamily: 'Montserrat',
          ),
          filled: true,
          fillColor: _inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryLight.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _accentColor),
          ),
          prefixIcon: Icon(icon, color: _accentColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Budget or Offer Price',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _accentColor,
            inactiveTrackColor: _primaryLight.withOpacity(0.3),
            thumbColor: _accentColor,
            overlayColor: _accentColor.withOpacity(0.2),
            valueIndicatorColor: _primaryDark,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          child: Slider(
            value: priceRange,
            min: 0,
            max: 5000,
            label: 'PKR ${priceRange.round()}',
            onChanged: (value) {
              setState(() {
                priceRange = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: _accentColor),
              SizedBox(width: 12),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Cash on delivery',
              style: TextStyle(
                fontSize: 14,
                color: _darkText,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancellation Policy',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
          SizedBox(height: 5),
          Text(
            'An order cancellation policy provides security to your business in the event that your customer cancels an order. You may reasonably charge a cancellation fee after a certain deadline, covering costs you suffered due to the cancellation.',
            style: TextStyle(
                color: Colors.grey.shade600, fontFamily: 'Montserrat'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplayAndOrderButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RS:${priceRange.round()}',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                        fontFamily: 'Montserrat'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Total Amount',
                    style: TextStyle(
                        fontSize: 14,
                        color: _primaryLight,
                        fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryDark,
                      fontFamily: 'Montserrat'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                elevation: 5,
                shadowColor: _accentColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0.0),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat')),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: TextStyle(fontFamily: 'Montserrat')),
          ))
              .toList(),
          onChanged: onChanged,
        ),
        SizedBox(height: 15.0),
      ],
    );
  }

  void _submitForm() async {
    if (!_validateForm()) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to submit request')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
        },
      );

      // Get client data from Firestore
      QuerySnapshot<Map<String, dynamic>> clientSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('email', isEqualTo: user.email)
          .get();

      if (clientSnapshot.docs.isEmpty) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfileScreen(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete your profile first'),
            action: SnackBarAction(
              label: 'Complete Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientProfileScreen(),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }

      DocumentSnapshot<Map<String, dynamic>> clientDoc = clientSnapshot.docs.first;
      Map<String, dynamic>? clientData = clientDoc.data();

      if (clientData == null || clientData['isProfileComplete'] != true) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfileScreen(),
          ),
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please complete your profile first')));
        return;
      }

      // Build category-specific details based on selected solar service
      Map<String, dynamic> categoryDetails = {};
      if (selectedService == 'Solar Installation') {
        categoryDetails = {
          'installationType': installationType,
          'systemCapacity': systemCapacity,
          'panelType': panelType,
          'batteryBackupRequired': batteryBackupRequired,
          'inverterType': inverterType,
          'mountingType': mountingType,
        };
      } else if (selectedService == 'Solar Cleaning') {
        categoryDetails = {
          'cleaningType': cleaningType,
          'cleaningMethod': cleaningMethod,
          'panelAccessibility': panelAccessibility,
        };
      }
      if (specialRequestsController.text.isNotEmpty) {
        categoryDetails['specialRequests'] = specialRequestsController.text;
      }

      Map<String, dynamic> serviceData = {
        'mainCategory': 'Solar Services',
        'subCategory': selectedService,
        'contactNumber': contactController.text,
        'selectedDate': selectedDate!.toIso8601String(),
        'selectedTime': selectedTime!.format(context),
        'priceRange': priceRange,
        'categorySpecificDetails': categoryDetails,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'clientId': clientDoc.id,
        'clientName': clientData['name'] ?? 'Unknown',
        'city': clientData['city'] ?? '',
        'clientEmail': user.email,
      };

      // Create request in Firestore
      DocumentReference requestRef = await FirebaseFirestore.instance
          .collection('serviceRequests')
          .add(serviceData);

      // Add request to client's subcollection
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(clientDoc.id)
          .collection('serviceRequests')
          .doc(requestRef.id)
          .set({
        ...serviceData,
        'requestId': requestRef.id,
      });

      Navigator.pop(context); // Dismiss loading indicator

      // Navigate to available vendors screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableVendorsScreen(
            serviceCategory: 'Solar Services',
            subCategory: selectedService!,
            serviceRequest: {
              ...serviceData,
              'requestId': requestRef.id,
            },
          ),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm() {
    if (selectedService == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a service type')));
      return false;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a date')));
      return false;
    }
    if (selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a time slot')));
      return false;
    }
    if (contactController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter your contact number')));
      return false;
    }
    // Validate category-specific fields for Solar Installation
    if (selectedService == 'Solar Installation') {
      if (installationType == null ||
          systemCapacity == null ||
          panelType == null ||
          inverterType == null ||
          mountingType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all installation details')));
        return false;
      }
    } else if (selectedService == 'Solar Cleaning') {
      if (cleaningType == null ||
          cleaningMethod == null ||
          panelAccessibility == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all cleaning details')));
        return false;
      }
    }
    return true;
  }
}

