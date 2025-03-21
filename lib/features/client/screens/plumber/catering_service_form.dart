import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services/features/client/screens/available_vendors_screen.dart';
import 'package:home_services/features/client/screens/Client_Profile _Screen.dart';

class CateringServiceForm extends StatefulWidget {
  @override
  _CateringServiceFormState createState() => _CateringServiceFormState();
}

class _CateringServiceFormState extends State<CateringServiceForm> {
  // UI Color and Style constants matching Painter Service Form
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);
  final Color _cardBg = Colors.white;
  final Color _inputBg = Colors.white;

  // Form field variables
  String? selectedService;
  TextEditingController contactController = TextEditingController();
  // Using a dedicated controller for guest count
  TextEditingController guestCountController = TextEditingController();
  // Controller for additional/special requests
  TextEditingController specialRequestsController = TextEditingController();

  // Fields for catering services
  String? serviceType; // Type of catering service (e.g., Kids’ Birthday Party)
  String? cateringRequirements;
  String? decorationPreferences;
  String? cuisinePreferences;
  String? dietaryRequirements;

  final List<Map<String, dynamic>> serviceCategories = [
    {'name': 'Birthday Party', 'icon': Icons.cake},
    {'name': 'Anniversary Celebration', 'icon': Icons.favorite},
    {'name': 'Corporate Event', 'icon': Icons.business},
    {'name': 'Wedding Catering', 'icon': Icons.handshake},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
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
                _buildTextField(contactController, 'Enter Mobile Number',
                    Icons.phone,
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
                    blurRadius: 8,
                    offset: Offset(0, 3),
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
                        color:
                        isSelected ? Colors.white : _primaryDark,
                        fontFamily: 'Montserrat'),
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
      case 'Birthday Party':
        return _buildBirthdayPartyFields();
      case 'Anniversary Celebration':
        return _buildAnniversaryCelebrationFields();
      case 'Corporate Event':
        return _buildCorporateEventFields();
      case 'Wedding Catering':
        return _buildWeddingCateringFields();
      default:
        return Container();
    }
  }

  Widget _buildBirthdayPartyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Birthday Service', serviceType, [
          'Kids’ Birthday Party',
          'Themed Birthday Celebration',
          'Surprise Birthday Party',
          'Adult Birthday Gathering',
        ], (value) => setState(() => serviceType = value)),
        _buildTextField(guestCountController, 'Guest Count (Approximate)',
            Icons.people,
            keyboardType: TextInputType.number),
        _buildDropdown('Catering Requirements', cateringRequirements, [
          'Snacks & Appetizers',
          'Full Meal Service',
          'Custom Birthday Cake',
        ], (value) => setState(() => cateringRequirements = value)),
        _buildDropdown('Decoration Preferences', decorationPreferences, [
          'Themed Decor',
          'Balloon Arrangements',
          'Stage Setup',
          'Customized Backdrops',
        ], (value) => setState(() => decorationPreferences = value)),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note,
            maxLines: 3),
      ],
    );
  }
  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        DropdownButtonFormField<String>(
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


  Widget _buildAnniversaryCelebrationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Anniversary Celebration', serviceType, [
          'Intimate Dinner Setup',
          'Family Gathering',
          'Grand Anniversary Party',
        ], (value) => setState(() => serviceType = value)),
        _buildTextField(guestCountController, 'Guest Count (Approximate)',
            Icons.people,
            keyboardType: TextInputType.number),
        _buildDropdown('Catering Options', cateringRequirements, [
          'Buffet Style',
          'Plated Dinner',
          'Customized Anniversary Cake',
        ], (value) => setState(() => cateringRequirements = value)),
        _buildDropdown('Decoration Preferences', decorationPreferences, [
          'Floral Decor',
          'Candlelight Theme',
          'Photo Booth Setup',
        ], (value) => setState(() => decorationPreferences = value)),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note,
            maxLines: 3),
      ],
    );
  }

  Widget _buildCorporateEventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Corporate Event', serviceType, [
          'Business Meeting Catering',
          'Conference Luncheon',
          'Office Party',
          'Product Launch Event',
        ], (value) => setState(() => serviceType = value)),
        _buildTextField(guestCountController, 'Guest Count (Approximate)',
            Icons.people,
            keyboardType: TextInputType.number),
        _buildDropdown('Catering Requirements', cateringRequirements, [
          'Tea & Coffee Service',
          'Breakfast Buffet',
          'Lunch/Dinner Buffet',
        ], (value) => setState(() => cateringRequirements = value)),
        _buildDropdown('Setup Preferences', decorationPreferences, [
          'Formal Table Arrangements',
          'Standing Buffet Style',
          'On-Site Chefs & Servers',
        ], (value) => setState(() => decorationPreferences = value)),
        _buildTextField(specialRequestsController, 'Special Requests', Icons.note,
            maxLines: 3),
      ],
    );
  }

  Widget _buildWeddingCateringFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Wedding Service', serviceType, [
          'Engagement Catering',
          'Mehndi & Sangeet Catering',
          'Wedding Day Full Service',
          'Walima Catering',
        ], (value) => setState(() => serviceType = value)),
        _buildTextField(guestCountController, 'Guest Count (Approximate)',
            Icons.people,
            keyboardType: TextInputType.number),
        _buildDropdown('Cuisine Preferences', cuisinePreferences, [
          'Desi / Pakistani / Indian',
          'Continental',
          'Chinese',
          'Arabic',
          'Custom Menu',
        ], (value) => setState(() => cuisinePreferences = value)),
        _buildDropdown('Special Dietary Requirements', dietaryRequirements, [
          'Vegetarian/Vegan',
          'Halal',
          'Allergy-Friendly Options',
        ], (value) => setState(() => dietaryRequirements = value)),
        _buildDropdown('Decoration & Table Setup', decorationPreferences, [
          'Buffet Style',
          'Fine Dining Setup',
          'Custom Table Centerpieces',
        ], (value) => setState(() => decorationPreferences = value)),
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
                    color: selectedDate ==
                        DateFormat('dd\nMMM').parse(date)
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
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat'),
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
              color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
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
              offset: Offset(0, 4)),
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

  // ---------------------------------------------------------------------------
  // Form Submission Logic (adapted from Painter Service Form)
  // ---------------------------------------------------------------------------
  void _submitForm() async {
    if (!_validateForm()) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please login to submit request')));
        return;
      }
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
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
          MaterialPageRoute(builder: (context) => ClientProfileScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete your profile first'),
            action: SnackBarAction(
              label: 'Complete Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientProfileScreen()),
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
          MaterialPageRoute(builder: (context) => ClientProfileScreen()),
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please complete your profile first')));
        return;
      }
      // Build category-specific details based on selected catering service
      Map<String, dynamic> categoryDetails = {};
      switch (selectedService) {
        case 'Birthday Party':
          categoryDetails = {
            'serviceType': serviceType,
            'guestCount': guestCountController.text,
            'cateringRequirements': cateringRequirements,
            'decorationPreferences': decorationPreferences,
            'specialRequests': specialRequestsController.text,
          };
          break;
        case 'Anniversary Celebration':
          categoryDetails = {
            'serviceType': serviceType,
            'guestCount': guestCountController.text,
            'cateringOptions': cateringRequirements,
            'decorationPreferences': decorationPreferences,
            'specialRequests': specialRequestsController.text,
          };
          break;
        case 'Corporate Event':
          categoryDetails = {
            'serviceType': serviceType,
            'guestCount': guestCountController.text,
            'cateringRequirements': cateringRequirements,
            'setupPreferences': decorationPreferences,
            'specialRequests': specialRequestsController.text,
          };
          break;
        case 'Wedding Catering':
          categoryDetails = {
            'serviceType': serviceType,
            'guestCount': guestCountController.text,
            'cuisinePreferences': cuisinePreferences,
            'dietaryRequirements': dietaryRequirements,
            'decorationPreferences': decorationPreferences,
            'specialRequests': specialRequestsController.text,
          };
          break;
        default:
          break;
      }
      Map<String, dynamic> serviceData = {
        'mainCategory': 'Indoor Catering',
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
          .set({...serviceData, 'requestId': requestRef.id});
      Navigator.pop(context); // Dismiss loading indicator
      // Navigate to Available Vendors screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableVendorsScreen(
            serviceCategory: 'Indoor Catering',
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
    // Validate category-specific fields for each catering service
    switch (selectedService) {
      case 'Birthday Party':
        if (serviceType == null ||
            guestCountController.text.isEmpty ||
            cateringRequirements == null ||
            decorationPreferences == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Birthday Party details')));
          return false;
        }
        break;
      case 'Anniversary Celebration':
        if (serviceType == null ||
            guestCountController.text.isEmpty ||
            cateringRequirements == null ||
            decorationPreferences == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Anniversary Celebration details')));
          return false;
        }
        break;
      case 'Corporate Event':
        if (serviceType == null ||
            guestCountController.text.isEmpty ||
            cateringRequirements == null ||
            decorationPreferences == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Corporate Event details')));
          return false;
        }
        break;
      case 'Wedding Catering':
        if (serviceType == null ||
            guestCountController.text.isEmpty ||
            cuisinePreferences == null ||
            dietaryRequirements == null ||
            decorationPreferences == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Wedding Catering details')));
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }
}
