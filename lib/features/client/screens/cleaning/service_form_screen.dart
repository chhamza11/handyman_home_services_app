import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting

class ServiceFormScreen extends StatefulWidget {
  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
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

  // New fields for Service Type
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

  final List<String> timeSlots = ['9:00-11:00 AM', '12:00-2:00 PM', '2:00-5:00 PM', '5:00-8:00 PM'];

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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('Service Request Form'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Service:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildServiceCategorySelector(),
              SizedBox(height: 20),
              _buildDateSelector(),
              // _buildServiceTypeSelector(),
              SizedBox(height: 20),
              _buildTimeSelector(),
              SizedBox(height: 20),
              // _buildDateSelector(),
              _buildServiceTypeSelector(),

              SizedBox(height: 20),
              _buildTextField(contactController, 'Enter Mobile Number', Icons.phone, keyboardType: TextInputType.phone),
              SizedBox(height: 20),

              SizedBox(height: 20),
              if (selectedService == 'Garden Care') ..._buildGardenCareFields(),
              if (selectedService == 'House Cleaning') ..._buildHouseCleaningFields(),
              if (selectedService == 'Clothes Cleaning') ..._buildClothesCleaningFields(),
              if (selectedService == 'Cooking') ..._buildCookingFields(),
              _buildPriceRangeSlider(),
              SizedBox(height: 20),
              // Pay Using Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue[300]),
                      SizedBox(width: 5),
                      Text('Pay Using:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('Cash on delivery', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 20),
              // Cancellation Policy Section
              Container(
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
              ),
              SizedBox(height: 20),
              // Price Display and Place Order Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RS:${priceRange.round()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Total', style: TextStyle(fontSize: 14)),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white), // Error icon
                        SizedBox(width: 5),
                        Text('Place Order', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0.0),
                ],
              ),

            ],
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
                color: selectedService == service['name'] ? Colors.blue : Colors.white,
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
                children: [
                  Icon(service['icon'], color: selectedService == service['name'] ? Colors.white : Colors.blue),
                  SizedBox(height: 5),
                  Text(
                    service['name'],
                    style: TextStyle(
                      color: selectedService == service['name'] ? Colors.white : Colors.blue,
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
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
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
                  color: isOneTimeSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "One Time",
                    style: TextStyle(
                      fontSize: 14,
                      color: isOneTimeSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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
                  color: !isOneTimeSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "Regularly",
                    style: TextStyle(
                      fontSize: 14,
                      color: !isOneTimeSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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
                    print("Selected Date: $selectedDate");
                  });
                },
                child: Container(
                  width: 80,
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedDate == DateFormat('dd\nMMM').parse(date) ? Colors.blue : Colors.white,
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
              selectedColor: Colors.blue,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  // Widget _buildPriceRangeSlider() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Your Budget or Offer Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       Slider(
  //         value: priceRange,
  //         min: 0,
  //         max: 1000,
  //         divisions: 100,
  //         label: 'PKR ${priceRange.round()}',
  //         onChanged: (value) {
  //           setState(() {
  //             priceRange = value;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

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
  // Widget _buildPriceRangeSlider() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Your Budget or Offer Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       Slider(
  //         value: priceRange,
  //         min: 0,
  //         max: 5000,
  //         // divisions: 50,
  //         label: 'PKR ${priceRange.round()}',
  //         onChanged: (value) {
  //           setState(() {
  //             priceRange = value;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }
  Widget _buildPriceRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Budget or Offer Price',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue,      // Color of the filled track
            inactiveTrackColor: Colors.grey,    // Color of the unfilled track
            thumbColor: Colors.blue,             // Color of the thumb (circle)
            overlayColor: Colors.red.withOpacity(0.2), // Color when dragging
            valueIndicatorColor: Colors.blue,   // Color of the value popup
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

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
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

  void _submitForm() {
    // Handle form submission
  }
}