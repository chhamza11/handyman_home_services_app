import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';

import 'Client_Profile _Screen.dart'; // Required for the blur effect

// Main screen widget for the Client Dashboard
class ClientDashboardScreen extends StatefulWidget {
  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String currentSide = 'client'; // Tracks the current user side (Client)
  int selectedService = -1; // Tracks the selected service; -1 means no service selected
  late PageController _pageController; // Controller for the page view to auto-scroll banners
  int _currentBannerIndex = 0; // Tracks the current banner index for auto-scrolling
  TextEditingController searchController = TextEditingController(); // Search bar controller

  // List of banner images to be displayed in the banner slider
  List<String> bannerImages = [
    'assets/banner/banner1.png',
    'assets/banner/banner2.png',
    'assets/banner/banner3.png',
  ];

  // List of services available in the dashboard
  List<Service> services = [
    Service('Home Labour Services', 'assets/ServicesIcon/labourservices.png'),
    Service('Indoor Catering & Event', 'assets/ServicesIcon/event.png'),
    Service('Paint Services', 'assets/ServicesIcon/paint.png'),
    Service('Furniture Repair', 'assets/ServicesIcon/farnaturerepair.png'),
    Service('Solar Services', 'assets/ServicesIcon/solar.png'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the page controller for auto-scrolling
    _startBannerAutoScroll(); // Start the auto-scrolling for the banner
  }

  // Function to auto-scroll the banner images every 3 seconds
  void _startBannerAutoScroll() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextIndex = _currentBannerIndex + 1;
        if (nextIndex >= bannerImages.length) {
          nextIndex = 0; // Loop back to the first banner
        }
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Logout function to clear the saved preferences and navigate to the login screen
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved preferences
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to Login screen
  }

  // Navigate to the respective service screen based on the selected service
  void _navigateToNextScreen() {
    if (selectedService == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a service first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String selectedServiceName = services[selectedService].name;

    // Navigate to the screen based on the selected service
    if (selectedServiceName == 'Home Labour Services') {
      Navigator.pushNamed(context, '/cleaning_service');
    } else if (selectedServiceName == 'Indoor Catering & Event') {
      Navigator.pushNamed(context, '/plumber_service');
    } else if (selectedServiceName == 'Paint Services') {
      Navigator.pushNamed(context, '/electrician_service');
    } else if (selectedServiceName == 'Furniture Repair') {
      Navigator.pushNamed(context, '/painter_service');
    } else if (selectedServiceName == 'Solar Services') {
      Navigator.pushNamed(context, '/carpenter_service');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text('Client Dashboard'), // AppBar title
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Client Options', // Drawer header text
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Switch to Vendor Side button
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Client Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch to Vendor Side'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/vendor_dashboard');
              },
            ),
            // Logout button
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding for the entire screen (left and right)
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return Column(
              children: [
                
                // Auto-scrolling banner
                Container(
                  height: screenHeight * 0.3, // Banner height is 30% of screen height
                  width: screenWidth,
                  padding: EdgeInsets.all(20.0), // Padding for the banner itself
                  child: Stack(
                    children: [
                      // PageView for the banner images
                      PageView.builder(
                        controller: _pageController,
                        itemCount: bannerImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index; // Update current banner index
                          });
                        },
                        itemBuilder: (context, index) {
                          // Return the banner image with blur effect and rounded corners
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
                              child: Image.asset(
                                bannerImages[index],
                                fit: BoxFit.fill,
                                width: screenWidth,
                                height: screenHeight * 0.3,
                              ),
                            ),
                          );
                        },
                      ),
                      // Dots indicator for the banner
                      Positioned(
                        bottom: 10,
                        left: screenWidth * 0.5 - 20,
                        child: DotsIndicator(
                          dotsCount: bannerImages.length,
                          position: _currentBannerIndex.toDouble(),
                          decorator: DotsDecorator(
                            activeColor: Colors.blue,
                            size: Size(10.0, 10.0),
                            activeSize: Size(12.0, 12.0),
                            spacing: EdgeInsets.symmetric(horizontal: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // GridView to display service options
                Expanded(
                  child: GridView.custom(
                    gridDelegate: SliverWovenGridDelegate.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      pattern: [
                        WovenGridTile(1), // First tile takes up normal space
                        WovenGridTile(
                          5 / 7, // Next tile takes up more space (5/7)
                          crossAxisRatio: 0.9, // Makes it wider
                          alignment: AlignmentDirectional.centerEnd, // Align to the right
                        ),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                          (context, index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedService = index; // Update the selected service
                          });
                          _navigateToNextScreen(); // Navigate based on selected service
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: selectedService == index
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: selectedService == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 4.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(2, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          transform: Matrix4.rotationX(0.05)..rotateY(0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Service image
                              Image.asset(
                                services[index].imageURL, // Load the image from assets
                                height: 105, // Adjust image size as needed
                              ),
                              SizedBox(height: 10),
                              // Service name text (with wrapping enabled)
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    services[index].name,
                                    style: TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center, // Centers the text
                                    overflow: TextOverflow.visible, // Ensures text is visible if it's long
                                    softWrap: true, // Wrap text if it's too long
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      childCount: services.length, // Total number of services
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Set the current index to the home tab
        onTap: (index) {
          // Handle bottom navigation tap
          if (index == 0) {
            // Home tab
            Navigator.pushReplacementNamed(context, '/client_dashboard');
          } else if (index == 1) {
            // Favorites tab
            Navigator.pushNamed(context, '/favorites');
          } else if (index == 2) {
            // Profile tab
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

// Service class to hold service name and image URL
class Service {
  final String name;
  final String imageURL;

  Service(this.name, this.imageURL);
}
