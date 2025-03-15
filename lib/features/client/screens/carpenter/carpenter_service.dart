import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'solar_service_form.dart';

class CarpenterServiceScreen extends StatefulWidget {
  @override
  _CarpenterServiceScreenState createState() => _CarpenterServiceScreenState();
}

class _CarpenterServiceScreenState extends State<CarpenterServiceScreen> {
  // Define UI color constants (matching PainterServiceScreen)
  final Color _primaryDark = Color(0xFF2B5F56);
  final Color _primaryLight = Color(0xFF4C8479);
  final Color _accentColor = Color(0xFFEDB232);
  final Color _darkText = Color(0xFF1A1A1A);

  // Cards list (will be initialized in initState to use the color constants)
  late final List<Map<String, dynamic>> _cards;

  @override
  void initState() {
    super.initState();
    _cards = [
      {
        'title': 'Solar Installation',
        'icon': Icons.bolt,
        'description': 'Professional installation of solar panels for homes and businesses.',
        'iconColor': _accentColor,
        'gradientColors': [
          _primaryDark.withOpacity(0.05),
          _primaryLight.withOpacity(0.15),
        ],
      },
      {
        'title': 'Solar Cleaning',
        'icon': Icons.cleaning_services,
        'description': 'Thorough cleaning of solar panels to maintain efficiency.',
        'iconColor': _primaryDark,
        'gradientColors': [
          _accentColor.withOpacity(0.1),
          _primaryDark.withOpacity(0.2),
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'Solar Services',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ),
          backgroundColor: _primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
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
          MaterialPageRoute(builder: (context) => SolarServiceForm()),
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
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: card['iconColor'].withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        card['icon'],
                        size: 35.0,
                        color: card['iconColor'],
                      ),
                    ),
                    SizedBox(width: 25.0),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
