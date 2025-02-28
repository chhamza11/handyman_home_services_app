import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/client/screens/painter/painter_service_form.dart';


class PainterServiceScreen extends StatefulWidget {
  @override
  _PainterServiceScreenState createState() => _PainterServiceScreenState();
}

class _PainterServiceScreenState extends State<PainterServiceScreen> {
  // List of cards with titles, icons, and descriptions
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Office Furniture',
      'icon': Icons.chair,
      'description': 'Repairing office chairs, tables, and work desks.'
    },
    {
      'title': 'Home Furniture',
      'icon': Icons.bed,
      'description': 'Fixing beds, cabinets, and wardrobes.'
    },
    {
      'title': 'Sofa & Upholstery',
      'icon': Icons.weekend,
      'description': 'Restoring sofas, cushions, and upholstery.'
    },
    {
      'title': 'Doors & Fixtures',
      'icon': Icons.door_back_door,
      'description': 'Repairing doors, hinges, and wooden structures.'
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
        title: Text('Furniture Repair Services'),
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
          MaterialPageRoute(builder: (context) => PainterServiceForm()),
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