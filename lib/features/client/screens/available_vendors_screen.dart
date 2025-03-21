import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_confirmation_screen.dart';
import 'package:flutter/material.dart';

class AvailableVendorsScreen extends StatefulWidget {
  final String serviceCategory;
  final String subCategory;
  final Map<String, dynamic> serviceRequest;

  const AvailableVendorsScreen({
    Key? key,
    required this.serviceCategory,
    required this.subCategory,
    required this.serviceRequest,
  }) : super(key: key);

  @override
  _AvailableVendorsScreenState createState() => _AvailableVendorsScreenState();
}

class _AvailableVendorsScreenState extends State<AvailableVendorsScreen> {
  String? selectedCity;
  Query<Map<String, dynamic>>? vendorsQuery;
  bool isCreatingIndexes = true;

  @override
  void initState() {
    super.initState();
    _tryQueries();
  }

  Future<void> _tryQueries() async {
    try {
      // Try query without city filter
      await FirebaseFirestore.instance
          .collection('vendors')
          .where('mainCategory', isEqualTo: widget.serviceCategory)
          .where('isProfileComplete', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      // Try query with city filter
      await FirebaseFirestore.instance
          .collection('vendors')
          .where('mainCategory', isEqualTo: widget.serviceCategory)
          .where('isProfileComplete', isEqualTo: true)
          .where('city', isEqualTo: 'Lahore') // Example city
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      setState(() {
        isCreatingIndexes = false;
      });
    } catch (e) {
      print('Index creation link: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setting up vendor search. This may take a few minutes.'),
            duration: Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Creating Indexes'),
                    content: Text(
                        'Please click the links in the debug console to create the required indexes. '
                            'This is a one-time setup process.'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    initializeQuery();
  }

  void initializeQuery() {
    print('Searching for category: ${widget.serviceCategory}');
    print('Searching for subcategory: ${widget.subCategory}');

    // Base query without city filter
    vendorsQuery = FirebaseFirestore.instance
        .collection('vendors')
        .where('mainCategory', isEqualTo: widget.serviceCategory)
        .where('isProfileComplete', isEqualTo: true);
  }

  void updateQuery() {
    setState(() {
      // Start with base query
      vendorsQuery = FirebaseFirestore.instance
          .collection('vendors')
          .where('mainCategory', isEqualTo: widget.serviceCategory)
          .where('isProfileComplete', isEqualTo: true);

      // Add city filter if selected
      if (selectedCity != null && selectedCity!.isNotEmpty) {
        vendorsQuery = vendorsQuery!.where('city', isEqualTo: selectedCity);
      }

      // Order by createdAt
      vendorsQuery = vendorsQuery!.orderBy('createdAt', descending: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Vendors'),
        backgroundColor: Color(0xFF2B5F56),
      ),
      body: isCreatingIndexes
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),),
            SizedBox(height: 16),
            Text(
              'Setting up vendor search...\nThis may take a few minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // City Filter
          Padding(
            padding: EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filter by City',
                border: OutlineInputBorder(),
              ),
              value: selectedCity,
              items: ['Lahore', 'Multan'] // Add your cities
                  .map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                  updateQuery();
                });
              },
            ),
          ),
          // Vendors List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: vendorsQuery?.snapshots(),
              builder: (context, snapshot) {
                // Add debug prints
                if (snapshot.hasData) {
                  print('Number of vendors found: ${snapshot.data!.docs.length}');
                  snapshot.data!.docs.forEach((doc) {
                    print('Vendor data: ${doc.data()}');
                  });
                }

                if (snapshot.hasError) {
                  print('Error in stream: ${snapshot.error}');
                  return Center(child: Text('Something went wrong: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No vendors available in ${selectedCity ?? "any city"}\n'
                              'for ${widget.serviceCategory}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Filter vendors who have the required subcategory
                final filteredVendors = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final subCategories = List<String>.from(data['subCategories'] ?? []);
                  return subCategories.contains(widget.subCategory);
                }).toList();

                if (filteredVendors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No vendors available for ${widget.subCategory}\n'
                              'in ${selectedCity ?? "any city"}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredVendors.length,
                  itemBuilder: (context, index) {
                    var vendor = filteredVendors[index];
                    var data = vendor.data();

                    return VendorCard(
                      vendor: data,
                      vendorId: vendor.id,
                      onSelect: () => _assignVendor(vendor.id, data['name']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _assignVendor(String vendorId, String vendorName) async {
    try {
      // First fetch the vendor's data to ensure we have the correct name
      final vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      
      final vendorData = vendorDoc.data();
      final actualVendorName = vendorData?['name'] ?? 'Unknown Vendor';

      DocumentReference requestRef = await FirebaseFirestore.instance
          .collection('serviceRequests')
          .add({
        ...widget.serviceRequest,
        'vendorId': vendorId,
        'vendorName': actualVendorName, // Use the fetched name
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'mainCategory': widget.serviceCategory,
      });

      // Show success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service request assigned to $actualVendorName')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RequestConfirmationScreen(
              requestId: requestRef.id,
              vendorName: actualVendorName,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error assigning vendor: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign vendor: $e')),
        );
      }
    }
  }
}

// Separate widget for vendor card
class VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final String vendorId;
  final VoidCallback onSelect;

  const VendorCard({
    Key? key,
    required this.vendor,
    required this.vendorId,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF2B5F56),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          vendor['name'] ?? 'Unknown Vendor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('Experience: ${vendor['experience'] ?? 'Not specified'}'),
            Text('Rating: ${vendor['rating']?.toString() ?? 'No ratings'}'),
            Text('City: ${vendor['city'] ?? 'Not specified'}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: Text('Select'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2B5F56),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
} 