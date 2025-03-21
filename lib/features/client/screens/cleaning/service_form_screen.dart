import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services/features/client/screens/available_vendors_screen.dart';
import 'package:home_services/features/client/screens/Client_Profile _Screen.dart';

class ServiceFormScreen extends StatefulWidget {
  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // UI Color and Style constants matching the Painter Service Form
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);
  final Color _cardBg = Colors.white;
  final Color _inputBg = Colors.white;

  // Service and form field variables
  String? selectedService;
  String? gardenSize;
  String? serviceFrequency;
  String? preferredTime;
  String? location;
  String? clothQuantity;
  String? roomQuantity;
  String? cuisineType;
  String? mealServing;
  List<String> selectedServices = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController additionalNotesController = TextEditingController();

  // New fields for user information
  TextEditingController addressController = TextEditingController();
  TextEditingController preferredDateTimeController = TextEditingController();
  String? paymentMethod;
  String? estimatedCost;
  String? bookingPolicy;

  // New fields for Garden Care
  String? gardenCareType;
  String? gardenEquipment;
  TextEditingController gardenInstructionsController = TextEditingController();

  // New fields for House Cleaning
  String? cleaningServiceType;
  String? homeSize;
  String? cleaningProducts;
  TextEditingController cleaningRequestsController = TextEditingController();

  // New fields for Clothes Cleaning
  String? clothingCareType;
  String? fabricType;
  String? washingPreference;
  String? detergentPreference;
  String? deliveryTimeframe;
  bool foldingRequired = false;

  // New fields for Cooking
  String? cookingServiceType;
  String? ingredientsProvided;
  TextEditingController dietaryRestrictionsController = TextEditingController();
  bool cleaningAfterCooking = false;

  // New field for Service Type selection
  String? selectedServiceType;

  final List<Map<String, dynamic>> serviceCategories = [
    {'name': 'Garden Care', 'icon': Icons.grass},
    {'name': 'House Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Clothes Cleaning', 'icon': Icons.local_laundry_service},
    {'name': 'Cooking', 'icon': Icons.restaurant},
  ];

  final List<String> gardenSizes = ['Small', 'Medium', 'Large'];
  final List<String> serviceFrequencies = ['One-time', 'Weekly', 'Monthly'];
  final List<String> roomQuantities = ['1 Room', '2 Rooms', '3 Rooms', '4+ Rooms'];
  final List<String> clothQuantities = ['1-5 Clothes', '6-10 Clothes', '11-20 Clothes', '20+ Clothes'];
  final List<String> cuisineTypes = ['Pakistani', 'Chinese', 'Italian', 'Continental', 'Custom'];
  final List<String> mealServings = ['1-2 People', '3-5 People', '6-10 People', '10+ People'];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double priceRange = 100.0; // Default price range
  bool termsAccepted = false;

  final List<String> timeSlots = [
    '9:00-11:00 AM',
    '12:00-2:00 PM',
    '2:00-5:00 PM',
    '5:00-8:00 PM'
  ];

  bool isOneTimeSelected = true; // Track the selected service type

  @override
  void initState() {
    super.initState();
    _loadSelectedService();
  }

  Future<void> _loadSelectedService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedService = prefs.getString('selectedService');
    setState(() {
      selectedService = storedService;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background matching Painter Service Form
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Service:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                ),
                SizedBox(height: 10),
                _buildServiceCategorySelector(),
                SizedBox(height: 20),
                _buildDateSelector(),
                SizedBox(height: 20),
                _buildTimeSelector(),
                SizedBox(height: 20),
                _buildServiceTypeSelector(),
                SizedBox(height: 20),
                _buildTextField(contactController, 'Enter Mobile Number', Icons.phone, keyboardType: TextInputType.phone),
                SizedBox(height: 20),
                if (selectedService == 'Garden Care') ..._buildGardenCareFields(),
                if (selectedService == 'House Cleaning') ..._buildHouseCleaningFields(),
                if (selectedService == 'Clothes Cleaning') ..._buildClothesCleaningFields(),
                if (selectedService == 'Cooking') ..._buildCookingFields(),
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
                  Icon(
                    service['icon'],
                    color: isSelected ? Colors.white : _primaryDark,
                  ),
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

  Widget _buildServiceTypeSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isOneTimeSelected = true;
                  selectedServiceType = 'One Time';
                  serviceFrequency = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: isOneTimeSelected ? _primaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "One Time",
                    style: TextStyle(
                      fontSize: 14,
                      color: isOneTimeSelected ? Colors.white : _darkText,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 0),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isOneTimeSelected = false;
                  selectedServiceType = 'Regularly';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: !isOneTimeSelected ? _primaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "Regularly",
                    style: TextStyle(
                      fontSize: 14,
                      color: !isOneTimeSelected ? Colors.white : _darkText,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    List<String> dates = _generateDateList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
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
                          color: selectedDate == DateFormat('dd\nMMM').parse(date)
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        dateParts[1],
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedDate == DateFormat('dd\nMMM').parse(date)
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
                color: selectedTime == _parseTimeSlot(time) ? Colors.white : Colors.black,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
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
          Text('Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
          SizedBox(height: 5),
          Text(
            'An order cancellation policy provides security to your business in the event that your customer cancels an order. You may reasonably charge a cancellation fee after a certain deadline, covering costs you suffered due to the cancellation.',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Montserrat'),
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

  List<Widget> _buildGardenCareFields() {
    return [
      _buildDropdown('Type of Garden Care Service', gardenCareType, [
        'Lawn Mowing',
        'Hedge Trimming',
        'Weed Removal',
        'Tree Pruning',
        'Planting & Landscaping',
        'Garden Cleaning'
      ], (value) => setState(() => gardenCareType = value)),
      _buildDropdown('Garden Size', gardenSize, ['Small', 'Medium', 'Large'], (value) => setState(() => gardenSize = value)),
      _buildDropdown('Service Frequency', serviceFrequency, ['One-time', 'Weekly', 'Monthly'], (value) => setState(() => serviceFrequency = value)),
      _buildDropdown('Required Equipment', gardenEquipment, ['Provided by user', 'Provided by service provider'], (value) => setState(() => gardenEquipment = value)),
      _buildTextField(gardenInstructionsController, 'Special Instructions', Icons.note, maxLines: 3),
    ];
  }

  List<Widget> _buildHouseCleaningFields() {
    return [
      _buildDropdown('Type of Cleaning Service', cleaningServiceType, [
        'Full House Cleaning',
        'Kitchen Deep Cleaning',
        'Bathroom Cleaning',
        'Floor Mopping & Sweeping',
        'Dusting & Furniture Cleaning'
      ], (value) => setState(() => cleaningServiceType = value)),
      _buildDropdown('Home Size', homeSize, ['1BHK', '2BHK', '3BHK', '4BHK'], (value) => setState(() => homeSize = value)),
      _buildDropdown('Number of Rooms to Clean', roomQuantity, ['1 Room', '2 Rooms', '3 Rooms', '4+ Rooms'], (value) => setState(() => roomQuantity = value)),
      _buildDropdown('Cleaning Products', cleaningProducts, ['Provided by user', 'Provided by service provider'], (value) => setState(() => cleaningProducts = value)),
      _buildTextField(cleaningRequestsController, 'Special Requests', Icons.note, maxLines: 3),
    ];
  }

  List<Widget> _buildClothesCleaningFields() {
    return [
      _buildDropdown('Number of Clothes', clothQuantity, ['1-5 Clothes', '6-10 Clothes', '11-20 Clothes', '20+ Clothes'], (value) => setState(() => clothQuantity = value)),
      _buildDropdown('Fabric Type', fabricType, ['Cotton', 'Wool', 'Silk', 'Synthetic'], (value) => setState(() => fabricType = value)),
      _buildDropdown('Washing Preferences', washingPreference, ['Regular Wash', 'Gentle Wash', 'Hand Wash Required'], (value) => setState(() => washingPreference = value)),
      _buildDropdown('Delivery Timeframe', deliveryTimeframe, ['Same-day', 'Next-day', '3 days'], (value) => setState(() => deliveryTimeframe = value)),
      SwitchListTile(
        title: Text('Folding Required?'),
        value: foldingRequired,
        onChanged: (value) {
          setState(() {
            foldingRequired = value;
          });
        },
      ),
    ];
  }

  List<Widget> _buildCookingFields() {
    return [
      _buildDropdown('Type of Cooking Service', cookingServiceType, [
        'Full Meal Preparation',
        'Specific Dish Preparation',
        'Catering for an Event',
        'Meal Prepping for the Week'
      ], (value) => setState(() => cookingServiceType = value)),
      _buildDropdown('Cooking Equipment Availability', gardenEquipment, ['Available', 'Not Available'], (value) => setState(() => gardenEquipment = value)),
      SwitchListTile(
        title: Text('Cleaning After Cooking Required?'),
        value: cleaningAfterCooking,
        onChanged: (value) {
          setState(() {
            cleaningAfterCooking = value;
          });
        },
      ),
      _buildTextField(dietaryRestrictionsController, 'Special Dietary Restrictions', Icons.note, maxLines: 3),
    ];
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
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

  // ---------------------------------------------------------------------------
  // Form Submission Logic (adapted from Painter Service Form)
  // ---------------------------------------------------------------------------
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
        Navigator.pop(context); // Dismiss loading
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
        Navigator.pop(context); // Dismiss loading
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

      // Build category-specific details based on the selected service
      Map<String, dynamic> categoryDetails = {};
      switch (selectedService) {
        case 'Garden Care':
          categoryDetails = {
            'gardenCareType': gardenCareType,
            'gardenSize': gardenSize,
            'serviceFrequency': serviceFrequency,
            'gardenEquipment': gardenEquipment,
            'specialInstructions': gardenInstructionsController.text,
          };
          break;
        case 'House Cleaning':
          categoryDetails = {
            'cleaningServiceType': cleaningServiceType,
            'homeSize': homeSize,
            'roomQuantity': roomQuantity,
            'cleaningProducts': cleaningProducts,
            'specialRequests': cleaningRequestsController.text,
          };
          break;
        case 'Clothes Cleaning':
          categoryDetails = {
            'clothQuantity': clothQuantity,
            'fabricType': fabricType,
            'washingPreference': washingPreference,
            'deliveryTimeframe': deliveryTimeframe,
            'foldingRequired': foldingRequired,
          };
          break;
        case 'Cooking':
          categoryDetails = {
            'cookingServiceType': cookingServiceType,
            'ingredientsProvided': ingredientsProvided,
            'cleaningAfterCooking': cleaningAfterCooking,
            'dietaryRestrictions': dietaryRestrictionsController.text,
          };
          break;
        default:
          break;
      }

      Map<String, dynamic> serviceData = {
        'mainCategory': 'Home Labour Services',
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

      // Navigate to Available Vendors screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableVendorsScreen(
            serviceCategory: 'Home Labour Services',
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
    // Validate category-specific fields
    switch (selectedService) {
      case 'Garden Care':
        if (gardenCareType == null || gardenSize == null || serviceFrequency == null || gardenEquipment == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Garden Care details')));
          return false;
        }
        break;
      case 'House Cleaning':
        if (cleaningServiceType == null || homeSize == null || roomQuantity == null || cleaningProducts == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all House Cleaning details')));
          return false;
        }
        break;
      case 'Clothes Cleaning':
        if (clothQuantity == null || fabricType == null || washingPreference == null || deliveryTimeframe == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Clothes Cleaning details')));
          return false;
        }
        break;
      case 'Cooking':
        if (cookingServiceType == null || ingredientsProvided == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill all Cooking details')));
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }
}
