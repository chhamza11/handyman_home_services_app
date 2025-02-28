import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/client/screens/plumber/catering_service_form.dart';


class cateringServiceScreen extends StatefulWidget {
  @override
  _cateringServiceScreenState createState() => _cateringServiceScreenState();
}

class _cateringServiceScreenState extends State<cateringServiceScreen> {
  // List of cards with titles, icons, and descriptions
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Birthday Party',
      'icon': Icons.cake,
      'description': 'Complete catering and decoration for birthday celebrations.'
    },
    {
      'title': 'Anniversary Celebration',
      'icon': Icons.favorite,
      'description': 'Special arrangements for memorable anniversary events.'
    },
    {
      'title': 'Corporate Event',
      'icon': Icons.business,
      'description': 'Professional catering services for business meetings and events.'
    },
    {
      'title': 'Wedding Catering',
      'icon': Icons.event,
      'description': 'Full wedding catering with a variety of cuisines and services.'
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
          MaterialPageRoute(builder: (context) => CateringServiceForm()),
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
                        fontSize: 18,
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