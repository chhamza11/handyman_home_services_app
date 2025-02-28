import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaintServiceFormScreen extends StatefulWidget {
  @override
  _PaintServiceFormScreenState createState() => _PaintServiceFormScreenState();
}

class _PaintServiceFormScreenState extends State<PaintServiceFormScreen> {
  String? selectedService;
  TextEditingController contactController = TextEditingController();
  TextEditingController specialRequestsController = TextEditingController();

  // Fields for painting services
  String? paintingType;
  String? surfaceType;
  String? paintType;
  String? paintProvidedBy;
  bool protectiveCoatingNeeded = false;
  bool designCustomizationRequired = false;

  final List<Map<String, dynamic>> serviceCategories = [
    {'name': 'Interior & Exterior Painting', 'icon': Icons.format_paint},
    {'name': 'Wood & Metal Painting', 'icon': Icons.chair},
    {'name': 'Decorative & Texture Painting', 'icon': Icons.texture},
    {'name': 'Door & Gate Painting', 'icon': Icons.door_sliding},
    {'name': 'Industrial Painting', 'icon': Icons.factory},
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double priceRange = 100.0; // Default price range

  final List<String> timeSlots = ['9:00-11:00 AM', '12:00-2:00 PM', '2:00-5:00 PM', '5:00-8:00 PM'];

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
              SizedBox(height: 20),
              _buildTimeSelector(),
              SizedBox(height: 20),
              _buildTextField(contactController, 'Enter Mobile Number', Icons.phone),
              SizedBox(height: 20),
              if (selectedService != null) ...[
                SizedBox(height: 20),
                _buildCategorySpecificFields(selectedService!),
              _buildPriceRangeSlider(),
              SizedBox(height: 20),
              _buildPaymentSection(),
                SizedBox(height: 20),
                _buildCancellationPolicy(),
              SizedBox(height: 20),
              _buildPriceDisplayAndOrderButton(),


              ],
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

  Widget _buildPaymentSection() {
    return Row(
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
    );
  }

  Widget _buildPriceDisplayAndOrderButton() {
    return Row(
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

  Widget _buildCategorySpecificFields(String category) {
    switch (category) {
      case 'Interior & Exterior Painting':
        return _buildInteriorExteriorPaintingFields();
      case 'Wood & Metal Painting':
        return _buildWoodMetalPaintingFields();
      case 'Decorative & Texture Painting':
        return _buildDecorativeTexturePaintingFields();
      case 'Door & Gate Painting':
        return _buildDoorGatePaintingFields();
      case 'Industrial Painting':
        return _buildIndustrialPaintingFields();
      default:
        return Container(); // Return an empty container if no category matches
    }
  }

  Widget _buildInteriorExteriorPaintingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Painting Service', paintingType, [
          'Interior Wall Painting',
          'Ceiling Painting',
          'Exterior Wall Painting',
          'Full House Painting',
        ], (value) => setState(() => paintingType = value)),
        _buildDropdown('Surface Type', surfaceType, [
          'Concrete',
          'Wood',
          'Drywall',
          'Brick',
        ], (value) => setState(() => surfaceType = value)),
        _buildDropdown('Paint Provided by', paintProvidedBy, [
          'User',
          'Service Provider',
        ], (value) => setState(() => paintProvidedBy = value)),
      ],
    );
  }

  Widget _buildWoodMetalPaintingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Painting Service', paintingType, [
          'Wooden Furniture Polishing',
          'Wooden Door Painting',
          'Metal Gate/Railing Painting',
          'Metal Furniture Coating',
        ], (value) => setState(() => paintingType = value)),
        _buildDropdown('Paint Finish Preference', surfaceType, [
          'Matte',
          'Glossy',
          'Satin',
        ], (value) => setState(() => surfaceType = value)),
        SwitchListTile(
          title: Text('Protective Coating Needed?'),
          value: protectiveCoatingNeeded,
          onChanged: (value) {
            setState(() {
              protectiveCoatingNeeded = value;
            });
          },
        ),
        _buildDropdown('Paint & Materials Provided by', paintProvidedBy, [
          'User',
          'Service Provider',
        ], (value) => setState(() => paintProvidedBy = value)),
      ],
    );
  }

  Widget _buildDecorativeTexturePaintingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Decorative Painting', paintingType, [
          'Wall Textures',
          'Murals & Artistic Designs',
          'Stencil Work',
          'Custom Artwork',
        ], (value) => setState(() => paintingType = value)),
        _buildDropdown('Paint Type & Finish', surfaceType, [
          'Metallic',
          'Sandstone',
          '3D Texture',
          'Faux Finish',
        ], (value) => setState(() => surfaceType = value)),
        _buildTextField(specialRequestsController, 'Wall Size (in sq. ft.)', Icons.square_foot, keyboardType: TextInputType.number),
        SwitchListTile(
          title: Text('Design Customization Required?'),
          value: designCustomizationRequired,
          onChanged: (value) {
            setState(() {
              designCustomizationRequired = value;
            });
          },
        ),
        _buildDropdown('Paint Provided by', paintProvidedBy, [
          'User',
          'Service Provider',
        ], (value) => setState(() => paintProvidedBy = value)),
      ],
    );
  }

  Widget _buildDoorGatePaintingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Door/Gate Painting', paintingType, [
          'Wooden Door Painting',
          'Metal Gate Painting',
          'PVC Door Coating',
          'Industrial Security Gate Painting',
        ], (value) => setState(() => paintingType = value)),
        _buildDropdown('Paint Type & Finish', surfaceType, [
          'Glossy',
          'Matte',
          'Waterproof',
        ], (value) => setState(() => surfaceType = value)),
        SwitchListTile(
          title: Text('Protective Coating Required?'),
          value: protectiveCoatingNeeded,
          onChanged: (value) {
            setState(() {
              protectiveCoatingNeeded = value;
            });
          },
        ),
        _buildDropdown('Paint & Materials Provided by', paintProvidedBy, [
          'User',
          'Service Provider',
        ], (value) => setState(() => paintProvidedBy = value)),
      ],
    );
  }

  Widget _buildIndustrialPaintingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Type of Industrial Painting', paintingType, [
          'Anti-Corrosion Coating',
          'Fireproof Coating',
          'Epoxy Floor Painting',
          'Machinery Painting',
        ], (value) => setState(() => paintingType = value)),
        _buildDropdown('Surface Type', surfaceType, [
          'Metal',
          'Concrete',
          'Brick',
          'Composite Panels',
        ], (value) => setState(() => surfaceType = value)),
        _buildDropdown('Paint Type', paintType, [
          'Industrial Grade',
          'Heat-Resistant',
          'Waterproof',
        ], (value) => setState(() => paintType = value)),
        _buildTextField(specialRequestsController, 'Special Instructions', Icons.note, maxLines: 3),
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

  List<String> _generateDateList() {
    List<String> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      dates.add(DateFormat('dd\nMMM').format(date));
    }
    return dates;
  }

  void _submitForm() {
    // Handle form submission
  }
}