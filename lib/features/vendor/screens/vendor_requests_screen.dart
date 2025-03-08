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
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue, // Match your app's theme
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'New Requests'),
            Tab(text: 'My Orders'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // New Requests Tab
              _buildNewRequestsTab(user),
              // My Orders Tab
              _buildMyOrdersTab(user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewRequestsTab(User? user) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('vendors')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, vendorSnapshot) {
        if (!vendorSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> vendorData = vendorSnapshot.data!.data() ?? {};

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _requestHandler.getAvailableRequests(
            vendorId: user!.uid,
            city: vendorData['city'] ?? '',
            serviceCategories: List<String>.from(vendorData['mainCategory'] != null ? [vendorData['mainCategory']] : []),
            subCategories: List<String>.from(vendorData['subCategories'] ?? []),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
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
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No new service requests available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                  onAccept: () => _requestHandler.acceptServiceRequest(
                    requestId: requests[index].id,
                    vendorId: user.uid,
                    vendorName: vendorData['name'] ?? '',
                    context: context,
                  ),
                  showAcceptButton: true,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyOrdersTab(User? user) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('serviceRequests')
          .where('vendorId', isEqualTo: user?.uid)
          .where('status', whereIn: ['assigned', 'in_progress', 'completed'])
          .orderBy('assignedAt', descending: true)
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
                  'No assigned orders yet',
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
              onAccept: () {}, // No accept button needed for assigned orders
              showAcceptButton: false,
              status: order['status'],
            );
          },
        );
      },
    );
  }
}

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final bool showAcceptButton;
  final String? status;

  const ServiceRequestCard({
    Key? key,
    required this.request,
    required this.onAccept,
    this.showAcceptButton = true,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                if (status != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status!.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Price: Rs. ${request['priceRange']?.toString() ?? '0'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
            if (showAcceptButton) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Accept Request'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
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