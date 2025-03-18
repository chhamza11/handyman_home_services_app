import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_services/features/vendor/services/vendor_request_handler.dart';

class VendorRequestsScreen extends StatefulWidget {
  @override
  _VendorRequestsScreenState createState() => _VendorRequestsScreenState();
}

class _VendorRequestsScreenState extends State<VendorRequestsScreen> with SingleTickerProviderStateMixin {
  final VendorRequestHandler _requestHandler = VendorRequestHandler();
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TabBar(
            controller: _tabController,
            labelColor: Color(0xFF2B5F56),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4C8479),
            tabs: [
              Tab(text: 'New Requests'),
              Tab(text: 'My Orders'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNewRequestsTab(user),
              _buildMyOrdersTab(user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewRequestsTab(User? user) {
    if (user == null) {
      print('User is null');
      return Center(child: Text('Please login to view requests'));
    }

    print('Current Auth User ID: ${user.uid}');

    // First get the vendor ID using the user's email
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vendors')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .snapshots(),
      builder: (context, vendorQuerySnapshot) {
        if (vendorQuerySnapshot.hasError) {
          print('Vendor query error: ${vendorQuerySnapshot.error}');
          return Center(child: Text('Error loading vendor profile'));
        }

        if (!vendorQuerySnapshot.hasData || vendorQuerySnapshot.data!.docs.isEmpty) {
          print('No vendor found for email: ${user.email}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Vendor profile not found.\nPlease complete your registration first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        final vendorDoc = vendorQuerySnapshot.data!.docs.first;
        final vendorId = vendorDoc.id;
        final vendorData = vendorDoc.data() as Map<String, dynamic>;
        
        print('Found vendor ID: $vendorId');
        print('Vendor Data: $vendorData');

        final mainCategory = vendorData['mainCategory'] as String?;

        if (mainCategory == null || mainCategory.isEmpty) {
          return Center(child: Text('Please complete your vendor profile'));
        }

        // Now get the service requests for this vendor
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('serviceRequests')
              .where('status', isEqualTo: 'assigned')
              .where('vendorId', isEqualTo: vendorId)
              .orderBy('assignedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Service requests error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final requests = snapshot.data?.docs ?? [];
            
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No new requests available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: requests.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final request = requests[index].data();
                return ServiceRequestCard(
                  request: request,
                  requestId: requests[index].id,
                  showActions: true,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyOrdersTab(User? user) {
    if (user == null) return Center(child: Text('Please login to view orders'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vendors')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .snapshots(),
      builder: (context, vendorSnapshot) {
        if (vendorSnapshot.hasError) {
          return Center(child: Text('Error loading vendor profile'));
        }

        if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('Vendor profile not found'));
        }

        final vendorDoc = vendorSnapshot.data!.docs.first;
        final vendorId = vendorDoc.id;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('serviceRequests')
              .where('vendorId', isEqualTo: vendorId)
              .where('status', whereIn: ['accepted', 'completed'])
              .orderBy('acceptedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data?.docs ?? [];

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No accepted orders yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: orders.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = orders[index].data();
                return ServiceRequestCard(
                  request: order,
                  requestId: orders[index].id,
                  showActions: false,
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget _buildDashboardStats(String vendorId) {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Dashboard',
  //           style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF2B5F56),
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         StreamBuilder<QuerySnapshot>(
  //           stream: FirebaseFirestore.instance
  //               .collection('serviceRequests')
  //               .where('vendorId', isEqualTo: vendorId)
  //               .snapshots(),
  //           builder: (context, snapshot) {
  //             if (snapshot.hasError || !snapshot.hasData) {
  //               return Center(child: CircularProgressIndicator());
  //             }
  //
  //             final requests = snapshot.data!.docs;
  //             int totalOrders = requests.length;
  //             int completedOrders = requests.where((doc) => doc['status'] == 'completed').length;
  //             int rejectedOrders = requests.where((doc) => doc['status'] == 'rejected').length;
  //             double totalEarnings = requests
  //                 .where((doc) => doc['status'] == 'completed')
  //                 .fold(0.0, (sum, doc) => sum + (doc['priceRange'] ?? 0.0));
  //
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 _buildStatCard(
  //                   'Total Orders',
  //                   totalOrders.toString(),
  //                   Icons.assignment,
  //                   Colors.blue,
  //                 ),
  //                 _buildStatCard(
  //                   'Completed',
  //                   completedOrders.toString(),
  //                   Icons.check_circle,
  //                   Colors.green,
  //                 ),
  //                 _buildStatCard(
  //                   'Rejected',
  //                   rejectedOrders.toString(),
  //                   Icons.cancel,
  //                   Colors.red,
  //                 ),
  //                 _buildStatCard(
  //                   'Earnings',
  //                   'Rs.${totalEarnings.toStringAsFixed(2)}',
  //                   Icons.monetization_on,
  //                   Color(0xFFEDB232),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.2),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, color: color, size: 32),
  //         SizedBox(height: 8),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             color: Colors.grey[600],
  //             fontSize: 14,
  //           ),
  //         ),
  //         SizedBox(height: 4),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String requestId;
  final bool showActions;
  final VendorRequestHandler _requestHandler = VendorRequestHandler();

  ServiceRequestCard({
    Key? key,
    required this.request,
    required this.requestId,
    this.showActions = true,
  }) : super(key: key);

  void _showRejectDialog(BuildContext context, String vendorId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                _requestHandler.rejectServiceRequest(
                  requestId: requestId,
                  vendorId: vendorId,
                  reason: reasonController.text,
                  context: context,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _completeOrder(BuildContext context, String vendorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Order'),
        content: Text('Are you sure you want to mark this order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _requestHandler.completeServiceRequest(
                requestId: requestId,
                vendorId: vendorId,
                context: context,
                priceRange: request['priceRange'] ?? 0.0,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request['subCategory'] ?? 'Unknown Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Price: Rs. ${request['priceRange'] != null ? double.parse(request['priceRange'].toString()).toStringAsFixed(2) : '0.00'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEDB232),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Client: ${request['clientName'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Contact: ${request['contactNumber'] ?? 'Not provided'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Date: ${request['selectedDate'] ?? 'Not specified'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              'Time: ${request['selectedTime'] ?? 'Not specified'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (request['categorySpecificDetails'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Service Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...(request['categorySpecificDetails'] as Map<String, dynamic>)
                  .entries
                  .where((e) => e.value != null && e.value.toString().isNotEmpty)
                  .map((e) => Text(
                        '${_formatKey(e.key)}: ${e.value}',
                        style: TextStyle(fontSize: 14),
                      )),
            ],
            if (showActions) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: user != null 
                      ? () => _showRejectDialog(context, user.uid)
                      : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Reject'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: user != null 
                      ? () => _requestHandler.acceptServiceRequest(
                          requestId: requestId,
                          vendorId: user.uid,
                          vendorName: request['vendorName'] ?? '',
                          context: context,
                        )
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2B5F56),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Accept'),
                  ),
                ],
              ),
            ],
            if (!showActions && request['status'] == 'accepted') ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: user != null 
                      ? () => _completeOrder(context, user.uid)
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Complete Order'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll(RegExp('([A-Z])'), ' \$1')
        .split('_')
        .map((word) => word.capitalize())
        .join(' ')
        .trim();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 