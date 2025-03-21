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
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
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
        if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final vendorDoc = vendorSnapshot.data!.docs.first;
        final vendorId = vendorDoc.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('serviceRequests')
              .where('vendorId', isEqualTo: vendorId)
              .orderBy('lastUpdated', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return Center(
                child: Text(
                  'No orders yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index].data() as Map<String, dynamic>;
                return ServiceRequestCard(
                  request: order,
                  requestId: orders[index].id,
                  showActions: false,
                  vendorId: vendorId,
                );
              },
            );
          },
        );
      },
    );
  }
}

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String requestId;
  final bool showActions;
  final String? vendorId;
  final VendorRequestHandler _requestHandler = VendorRequestHandler();

  ServiceRequestCard({
    Key? key,
    required this.request,
    required this.requestId,
    this.showActions = true,
    this.vendorId,
  }) : super(key: key);

  void _handleComplete(BuildContext context) {
    if (vendorId == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Complete Order'),
        content: Text('Are you sure you want to mark this order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _requestHandler.completeServiceRequest(
                requestId: requestId,
                vendorId: vendorId!,
                context: context,
                priceRange: double.tryParse(request['priceRange'].toString()) ?? 0.0,
              );
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
    final status = request['status'] as String?;
    final isAccepted = status == 'accepted';
    final isCompleted = status == 'completed';

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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getStatusColor(status),
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
            if (!showActions && isAccepted) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleComplete(context),
                    icon: Icon(Icons.check_circle),
                    label: Text('Complete Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            if (!showActions && isCompleted) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'accepted':
        return Colors.blue;
      case 'assigned':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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