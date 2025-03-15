import 'package:flutter/material.dart';
import 'package:home_services/features/client/screens/Venders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_services/features/client/screens/electrician/paint_service_form.dart';

class ElectricianServiceScreen extends StatefulWidget {
  @override
  _ElectricianServiceScreenState createState() => _ElectricianServiceScreenState();
}

class _ElectricianServiceScreenState extends State<ElectricianServiceScreen> {
  // Define UI color constants (matching PainterServiceScreen)
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);

  // List of cards with titles, icons, descriptions, and custom colors/gradients
  late final List<Map<String, dynamic>> _cards;

  @override
  void initState() {
    super.initState();
    _cards = [
      {
        'title': 'Interior & Exterior Painting',
        'icon': Icons.format_paint,
        'description': 'High-quality painting for walls, ceilings, and exteriors.',
        'iconColor': _accentColor,
        'gradientColors': [
          _primaryDark.withOpacity(0.05),
          _primaryLight.withOpacity(0.15),
        ],
      },
      {
        'title': 'Wood & Metal Painting',
        'icon': Icons.chair,
        'description': 'Polishing and painting for furniture, doors, and railings.',
        'iconColor': _primaryLight,
        'gradientColors': [
          _accentColor.withOpacity(0.1),
          _primaryDark.withOpacity(0.2),
        ],
      },
      {
        'title': 'Decorative & Texture Painting',
        'icon': Icons.texture,
        'description': 'Creative textures, murals, and artistic designs.',
        'iconColor': Color(0xFFE6A012), // Darker gold
        'gradientColors': [
          _primaryLight.withOpacity(0.1),
          _primaryDark.withOpacity(0.2),
        ],
      },
      {
        'title': 'Door & Gate Painting',
        'icon': Icons.door_sliding,
        'description': 'Smooth and even paint application for all surfaces.',
        'iconColor': _primaryDark,
        'gradientColors': [
          _accentColor.withOpacity(0.1),
          _primaryLight.withOpacity(0.2),
        ],
      },
      {
        'title': 'Industrial Painting',
        'icon': Icons.factory,
        'description': 'Protective coatings for factories and warehouses.',
        'iconColor': Color(0xFF3A7268), // Medium primary
        'gradientColors': [
          _primaryDark.withOpacity(0.05),
          _primaryLight.withOpacity(0.15),
        ],
      },
    ];
  }

  Future<void> _saveSelectedService(String service) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedService', service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a custom AppBar with PreferredSize and rounded bottom
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: _primaryDark,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'Paint Services',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      // Use a gradient background similar to PainterServiceScreen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryDark.withOpacity(0.20),
              _primaryLight.withOpacity(0.70),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: ListView.builder(
            itemCount: _cards.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildCard(index);
            },
          ),
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
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Card(
          elevation: 12,
          shadowColor: _primaryDark.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: card['gradientColors'],
              ),
            ),
            child: SizedBox(
              height: 175.0,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: card['iconColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        card['icon'],
                        size: 35.0,
                        color: card['iconColor'],
                      ),
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
                              fontWeight: FontWeight.w700,
                              color: _darkText,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            card['description'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _primaryLight,
                              height: 1.5,
                              letterSpacing: 0.3,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
