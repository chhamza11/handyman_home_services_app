import 'package:flutter/material.dart';
import 'package:home_services/features/client/screens/Venders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/client/screens/electrician/paint_service_form.dart';

class ElectricianServiceScreen extends StatefulWidget {
  @override
  _ElectricianServiceScreenState createState() => _ElectricianServiceScreenState();
}

class _ElectricianServiceScreenState extends State<ElectricianServiceScreen> {
  // List of cards with titles, icons, and descriptions
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Interior & Exterior Painting',
      'icon': Icons.format_paint,
      'description': 'High-quality painting for walls, ceilings, and exteriors.'
    },
    {
      'title': 'Wood & Metal Painting',
      'icon': Icons.chair,
      'description': 'Polishing and painting for furniture, doors, and railings.'
    },
    {
      'title': 'Decorative & Texture Painting',
      'icon': Icons.texture,
      'description': 'Creative textures, murals, and artistic designs.'
    },
    {
      'title': 'Door & Gate Painting',
      'icon': Icons.door_sliding,
      'description': 'Smooth and even paint application for all surfaces.'
    },
    {
      'title': 'Industrial Painting',
      'icon': Icons.factory,
      'description': 'Protective coatings for factories and warehouses.'
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
        title: Text('Paint Services'),
        backgroundColor: Colors.blue,
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
          MaterialPageRoute(builder: (context) => PaintServiceFormScreen()),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      card['description'],
                      style: TextStyle(
                        fontSize: 13,
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