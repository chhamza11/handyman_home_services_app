import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ClientDashboardScreen extends StatefulWidget {
  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String currentSide = 'client'; // Default side is Client
  int _selectedIndex = 0; // Track the selected index in the BottomNavigationBar
  int selectedService = -1; // -1 means no service is selected

  List<Service> services = [
    Service('Cleaning',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
    Service('Plumber',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-plumber-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
    Service('Electrician',
        'https://img.icons8.com/external-wanicon-flat-wanicon/2x/external-multimeter-car-service-wanicon-flat-wanicon.png'),
    Service('Painter',
        'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-painter-male-occupation-avatar-itim2101-flat-itim2101.png'),
    Service('Carpenter', 'https://img.icons8.com/fluency/2x/drill.png'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSidePreference();
  }

  Future<void> _loadSidePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSide = prefs.getString('side') ?? 'client'; // Default to client
    });
  }

  Future<void> _saveSidePreference(String side) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('side', side); // Save the side preference
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved preferences
    Navigator.pushReplacementNamed(
        context, '/login'); // Redirect to Login screen
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName'); // Check if profile exists

      if (userName != null && userName.isNotEmpty) {
        Navigator.pushNamed(context, '/client_profile');
      } else {
        Navigator.pushNamed(context, '/create_profile');
      }
    }
  }

  // Navigate to the next screen based on the selected service
  void _navigateToNextScreen() {
    if (selectedService == -1) {
      // Show a warning if no service is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a service first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String selectedServiceName = services[selectedService].name;

    // Navigate to the respective screen based on the service
    if (selectedServiceName == 'Cleaning') {
      Navigator.pushNamed(context, '/cleaning_service');
    } else if (selectedServiceName == 'Plumber') {
      Navigator.pushNamed(context, '/plumber_service');
    } else if (selectedServiceName == 'Electrician') {
      Navigator.pushNamed(context, '/electrician_service');
    } else if (selectedServiceName == 'Painter') {
      Navigator.pushNamed(context, '/painter_service');
    } else if (selectedServiceName == 'Carpenter') {
      Navigator.pushNamed(context, '/carpenter_service');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Client Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Client Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Vendor Side'),
              onTap: () async {
                await _saveSidePreference('vendor');
                Navigator.of(context).pop(); // Close drawer
                Navigator.pushReplacementNamed(context, '/vendor_dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                height: screenHeight * 0.4,
                width: screenWidth,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 4 : 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: serviceContainer(
                        services[index].imageURL,
                        services[index].name,
                        index,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.2),
                      topRight: Radius.circular(screenWidth * 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      FadeInUp(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1),
                          child: Center(
                            child: Text(
                              'Easy, reliable way to take\ncare of your home',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      FadeInUp(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1),
                          child: Center(
                            child: Text(
                              'We provide you with the best people to help take care of your home.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      FadeInUp(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.1),
                          child: MaterialButton(
                            elevation: 0,
                            color: Colors.black,
                            onPressed: _navigateToNextScreen,
                            height: screenHeight * 0.065,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = index; // Update the selected service
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedService == index
              ? Colors.blue.shade100
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: selectedService == index ? Colors.blue : Colors.grey.shade300,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(image, height: 40),
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String name;
  final String imageURL;

  Service(this.name, this.imageURL);
}
