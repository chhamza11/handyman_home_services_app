import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_form_screen.dart';


class CleaningServiceScreen extends StatefulWidget {
  @override
  _CleaningServiceScreenState createState() => _CleaningServiceScreenState();
}

class _CleaningServiceScreenState extends State<CleaningServiceScreen> {
  // List of cards with titles, icons, and descriptions
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Garden Care',
      'icon': Icons.grass,
      'description': 'Trimming, watering, and maintaining your garden.'
    },
    {
      'title': 'House Cleaning',
      'icon': Icons.cleaning_services,
      'description': 'Comprehensive cleaning for your entire house.'
    },
    {
      'title': 'Clothe Cleaning',
      'icon': Icons.local_laundry_service,
      'description': 'Washing, ironing, and folding your clothes.'
    },
    {
      'title': 'Cooking',
      'icon': Icons.restaurant,
      'description': 'Preparing delicious and healthy meals for your family.'
    },
  ];

  Future<void> _saveSelectedService(String service) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedService', service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cleaning Services'),
        backgroundColor: Colors.blue[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: _cards.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () async {
        await _saveSelectedService(card['title']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServiceFormScreen()),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue.shade50,
        child: Container(
          height: 175.0,
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                card['icon'],
                size: 50.0,
                color: Colors.blueAccent,
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      card['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}