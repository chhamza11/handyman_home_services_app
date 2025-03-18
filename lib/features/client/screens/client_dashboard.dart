import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:home_services/common/providers/main_controller.dart';

import 'Client_Profile _Screen.dart'; // Required for the blur effect
import 'order_history_screen.dart'; // Import the Order History Screen

// Main screen widget for the Client Dashboard
class ClientDashboardScreen extends StatefulWidget {
  @override
  _ClientDashboardScreenState createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String currentSide = 'client'; // Tracks the current user side (Client)
  late PageController
      _pageController; // Controller for the page view to auto-scroll banners
  int _currentBannerIndex =
      0; // Tracks the current banner index for auto-scrolling
  TextEditingController searchController =
      TextEditingController(); // Search bar controller
  bool _isSearching = false;
  bool _isHovered = false;
  FocusNode _searchFocusNode = FocusNode();
  int? _tempSelectedService; // For temporary selection display

  // List of banner images to be displayed in the banner slider
  List<String> bannerImages = [
    'assets/banner/banner3.png',
    'assets/banner/banner3.png',
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
    _pageController =
        PageController(); // Initialize the page controller for auto-scrolling
    _startBannerAutoScroll(); // Start the auto-scrolling for the banner
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
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

  // Update the logout function
  Future<void> _logout() async {
    try {
      // Get the MainController
      final mainController =
          Provider.of<MainController>(context, listen: false);

      // This will handle Firebase signout, clear SharedPreferences, and Hive storage
      await mainController.logout();

      // Navigate to login screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to the respective service screen based on the selected service
  void _navigateToNextScreen(int index) {
    String selectedServiceName = services[index].name;

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
      backgroundColor: Color(0xFF2B5F56),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Client Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: Column(
            children: [
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: 65,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: _isSearching
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _isSearching
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: _isSearching
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: _isSearching
                        ? TextField(
                            controller: searchController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search Product',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 16, right: 8),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.tune,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      // Add filter functionality here
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        _isSearching = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                            ),
                          )
                        : Row(
                            children: [
                              SizedBox(width: 16),
                              Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.7),
                                size: 34,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Search Product',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.tune,
                                color: Colors.white.withOpacity(0.7),
                                size: 22,
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2B5F56), Color(0xFF2B5F79)],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Text(
                    'Client Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.black54),
                    title: Text('Client Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientProfileScreen()),
                    ),
                  ),
                  Divider(color: Colors.grey[200], thickness: 1),
                  ListTile(
                    leading: Icon(Icons.swap_horiz, color: Colors.black54),
                    title: Text('Switch to Vendor Side', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.pushReplacementNamed(context, '/vendor_dashboard'),
                  ),
                  Divider(color: Colors.grey[200], thickness: 1),
                  ListTile(
                    leading: Icon(Icons.history, color: Colors.black54),
                    title: Text('Order History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                    ),
                  ),
                  Divider(color: Colors.grey[200], thickness: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Banner Container
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      13), // Slightly smaller than container border radius
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: bannerImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            bannerImages[index],
                            fit: BoxFit
                                .cover, // Changed to cover for better fitting
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: MediaQuery.of(context).size.width * 0.5 - 40,
                        child: DotsIndicator(
                          dotsCount: bannerImages.length,
                          position: _currentBannerIndex.toDouble(),
                          decorator: DotsDecorator(
                            activeColor: Color(0xFFFFB74D),
                            size: Size(10.0, 10.0),
                            activeSize: Size(12.0, 12.0),
                            spacing: EdgeInsets.symmetric(horizontal: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Services Grid
              GridView.custom(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverWovenGridDelegate.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  pattern: [
                    WovenGridTile(1),
                    WovenGridTile(
                      5 / 7,
                      crossAxisRatio: 0.9,
                      alignment: AlignmentDirectional.centerEnd,
                    ),
                  ],
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => GestureDetector(
                    onTapDown: (_) {
                      // When user starts pressing
                      setState(() {
                        _tempSelectedService = index;
                      });
                    },
                    onTapUp: (_) {
                      // When user releases the tap
                      setState(() {
                        _tempSelectedService = null;
                        _navigateToNextScreen(index); // Pass the index directly
                      });
                    },
                    onTapCancel: () {
                      // If the tap is canceled
                      setState(() {
                        _tempSelectedService = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _tempSelectedService == index
                              ? [
                                  Color(0xFF2B5F56).withOpacity(0.3),
                                  Color(0xFF2B5F56).withOpacity(0.4),
                                ]
                              : [
                                  Color(0xFFD8C7B7)
                                      .withOpacity(1), // 50% opacity
                                  Colors.white.withOpacity(0.2),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(2, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      transform: Matrix4.rotationX(0.05)..rotateY(0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            services[index].imageURL,
                            height: 105,
                          ),
                          SizedBox(height: 10),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                services[index].name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  childCount: services.length,
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite),
      //       label: 'Favorites',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   currentIndex: 0, // Set the current index to the home tab
      //   onTap: (index) {
      //     // Handle bottom navigation tap
      //     if (index == 0) {
      //       // Home tab
      //       Navigator.pushReplacementNamed(context, '/client_dashboard');
      //     } else if (index == 1) {
      //       // Favorites tab
      //       Navigator.pushNamed(context, '/favorites');
      //     } else if (index == 2) {
      //       // Profile tab
      //       Navigator.pushNamed(context, '/profile');
      //     }
      //   },
      // ),
    );
  }
}



// Service class to hold service name and image URL
class Service {
  final String name;
  final String imageURL;

  Service(this.name, this.imageURL);
}
