import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:home_services/features/client/screens/Venders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services/features/client/screens/available_vendors_screen.dart';
import 'package:home_services/features/client/screens/Client_Profile _Screen.dart';

class PainterServiceForm extends StatefulWidget {
  @override
  _PainterServiceFormState createState() => _PainterServiceFormState();
}

class _PainterServiceFormState extends State<PainterServiceForm> {
  // Update color constants
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);
  final Color _cardBg = Colors.white;
  final Color _inputBg = Colors.white;

  String? selectedService;
  TextEditingController contactController = TextEditingController();
  TextEditingController specialRequestsController = TextEditingController();

  // Fields for furniture repair services
  String? repairType;
  String? numberOfItems;
  String? materialType;
  String? upholsteryMaterial;
  bool colorMatchingRequired = false;

  final List<Map<String, dynamic>> serviceCategories = [
    {'name': 'Office Furniture Repair', 'icon': Icons.chair},
    {'name': 'Home Furniture Repair', 'icon': Icons.bed},
    {'name': 'Sofa & Upholstery Repair', 'icon': Icons.weekend},
    {'name': 'Doors & Fixtures Repair', 'icon': Icons.door_back_door},
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double priceRange = 100.0; // Default price range

  final List<String> timeSlots = ['9:00-11:00 AM', '12:00-2:00 PM', '2:00-5:00 PM', '5:00-8:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],  // Light background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
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
          backgroundColor: _primaryDark,
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Service:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 10),
                _buildServiceCategorySelector(),
                SizedBox(height: 20),
                _buildDateSelector(),
                SizedBox(height: 20),
                _buildTimeSelector(),
                SizedBox(height: 20),
                _buildTextField(contactController, 'Enter Mobile Number', Icons.phone, keyboardType: TextInputType.phone),
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
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? _primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _primaryDark.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    service['icon'],
                    color: isSelected ? Colors.white : _accentColor,
                    size: 30,
                  ),
                  SizedBox(height: 8),
                  Text(
                    service['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _darkText,
                      fontWeight: FontWeight.w600,
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
      case 'Office Furniture Repair':
        return _buildOfficeFurnitureRepairFields();
      case 'Home Furniture Repair':
        return _buildHomeFurnitureRepairFields();
      case 'Sofa & Upholstery Repair':
        return _buildSofaUpholsteryRepairFields();
      case 'Doors & Fixtures Repair':
        return _buildDoorsFixturesRepairFields();
      default:
        return Container(); // Return an empty container if no category matches
    }
  }

  Widget _buildOfficeFurnitureRepairFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Type of Office Furniture Repair', repairType, [
                'Office Chair Repair (Wheels, Cushion, Hydraulic)',
                'Work Desk Repair (Wood Damage, Loose Parts)',
                'Meeting Table Restoration',
                'Cabinet/Drawer Fixing',
              ], (value) => setState(() => repairType = value)),
            ),
          ],
        ),
        _buildTextField(specialRequestsController, 'Number of Items to Repair', Icons.format_list_numbered, keyboardType: TextInputType.number),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Material Type', materialType, [
                'Wood',
                'Metal',
                'Glass',
                'Mixed Material',
              ], (value) => setState(() => materialType = value)),
            ),
          ],
        ),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note, maxLines: 3),
      ],
    );
  }

  Widget _buildHomeFurnitureRepairFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Type of Home Furniture Repair', repairType, [
                'Bed Frame Repair (Loose Joints, Broken Panels)',
                'Wardrobe Fixing (Hinges, Sliding Doors)',
                'Cabinet Restoration',
                'Dining Table & Chairs Repair',
              ], (value) => setState(() => repairType = value)),
            ),
          ],
        ),
        _buildTextField(specialRequestsController, 'Number of Items to Repair', Icons.format_list_numbered, keyboardType: TextInputType.number),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Material Type', materialType, [
                'Wood',
                'MDF/Plywood',
                'Metal',
              ], (value) => setState(() => materialType = value)),
            ),
          ],
        ),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note, maxLines: 3),
      ],
    );
  }

  Widget _buildSofaUpholsteryRepairFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Sofa/Upholstery Repair', repairType, [
          'Sofa Frame Repair',
          'Cushion Refilling & Restitching',
          'Upholstery Cleaning & Restoration',
          'Recliner Mechanism Fixing',
        ], (value) => setState(() => repairType = value)),
        _buildDropdown('Upholstery Material', upholsteryMaterial, [
          'Leather',
          'Fabric',
          'Velvet',
          'Synthetic Material',
        ], (value) => setState(() => upholsteryMaterial = value)),
        SwitchListTile(
          title: Text('Color/Material Matching Required?'),
          value: colorMatchingRequired,
          onChanged: (value) {
            setState(() {
              colorMatchingRequired = value;
            });
          },
        ),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note, maxLines: 3),
      ],
    );
  }

  Widget _buildDoorsFixturesRepairFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Type of Door/Fitting Repair', repairType, [
                'Wooden Door Repair (Scratches, Cracks)',
                'Hinges & Lock Fixing',
                'Door Frame Repair',
                'Window Frame & Panel Fixing',
              ], (value) => setState(() => repairType = value)),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Door Type', materialType, [
                'Wooden',
                'Glass',
                'Metal',
              ], (value) => setState(() => materialType = value)),
            ),
          ],
        ),
        _buildTextField(specialRequestsController, 'Number of Doors/Fixtures to Repair', Icons.format_list_numbered, keyboardType: TextInputType.number),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note, maxLines: 3),
      ],
    );
  }

  Widget _buildDateSelector() {
    List<String> dates = _generateDateList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    color: selectedDate == DateFormat('dd\nMMM').parse(date) ? const Color(0xFF2B5F56)  : Colors.white,
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
                        dateParts[0], // Day
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedDate == DateFormat('dd\nMMM').parse(date) ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        dateParts[1], // Month
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedDate == DateFormat('dd\nMMM').parse(date) ? Colors.white : Colors.black,
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
            padding: const EdgeInsets.symmetric(horizontal: 5.0), // Add padding between time slots
            child: ChoiceChip(
              label: Text(time),
              selected: selectedTime == _parseTimeSlot(time), // Check if this time is selected
              onSelected: (selected) {
                setState(() {
                  selectedTime = selected ? _parseTimeSlot(time) : null; // Only select the clicked time slot
                });
              },
              selectedColor: const Color(0xFF2B5F56) ,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedTime == _parseTimeSlot(time) ? Colors.white : Colors.black,
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Budget or Offer Price',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkText,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 20),
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
      ),
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
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: _primaryLight,
                      fontFamily: 'Montserrat',
                    ),
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
                    fontFamily: 'Montserrat',
                  ),
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
          Text('Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
            'An order cancellation policy provides security to your business in the event that your customer cancels an order. You may reasonably charge a cancellation fee after a certain deadline, covering costs you suffered due to the cancellation.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  List<String> _generateDateList() {
    List<String> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      dates.add(DateFormat('dd\nMMM').format(date));
    }
    return dates;
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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

      // Get client data
      QuerySnapshot<Map<String, dynamic>> clientSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('email', isEqualTo: user.email)
          .get();

      if (clientSnapshot.docs.isEmpty) {
        Navigator.pop(context); // Dismiss loading indicator
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

      // Get the client document
      DocumentSnapshot<Map<String, dynamic>> clientDoc = clientSnapshot.docs.first;
      Map<String, dynamic>? clientData = clientDoc.data();

      if (clientData == null || clientData['isProfileComplete'] != true) {
        Navigator.pop(context); // Dismiss loading indicator
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfileScreen(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete your profile first')),
        );
        return;
      }

      // Create category-specific details based on selected service
      Map<String, dynamic> categoryDetails = {};
      
      switch (selectedService) {
        case 'Office Furniture Repair':
        case 'Home Furniture Repair':
        case 'Sofa & Upholstery Repair':
        case 'Doors & Fixtures Repair':
          categoryDetails = {
            'repairType': repairType,
            'numberOfItems': numberOfItems,
            'materialType': materialType,
            'colorMatchingRequired': colorMatchingRequired,
            'upholsteryMaterial': upholsteryMaterial,
          };
          break;
      }

      // Add special requests if any
      if (specialRequestsController.text.isNotEmpty) {
        categoryDetails['specialRequests'] = specialRequestsController.text;
      }

      Map<String, dynamic> serviceData = {
        'mainCategory': 'Furniture Repair Services',
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

      // Dismiss loading indicator
      Navigator.pop(context);

      // Navigate to available vendors screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableVendorsScreen(
            serviceCategory: 'Furniture Repair Services',
            subCategory: selectedService!,
            serviceRequest: {
              ...serviceData,
              'requestId': requestRef.id,
            },
          ),
        ),
      );

    } catch (e) {
      // Dismiss loading indicator if showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a service type')),
      );
      return false;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return false;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a time slot')),
      );
      return false;
    }

    if (contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your contact number')),
      );
      return false;
    }

    // Validate category-specific fields
    if (selectedService != null) {
      if (repairType == null || materialType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all repair details')),
        );
        return false;
      }
    }

    return true;
  }
}