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
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    try {
      await _requestHandler.initNotifications(context);
      _listenForNewRequests();
    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  void _listenForNewRequests() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.email == null) return;

    FirebaseFirestore.instance
        .collection('vendors')
        .where('email', isEqualTo: currentUser!.email)
        .limit(1)
        .get()
        .then((vendorSnapshot) {
      if (vendorSnapshot.docs.isNotEmpty) {
        final vendorData = vendorSnapshot.docs.first.data();
        final vendorCity = vendorData['city'] as String?;
        final categories = vendorData['subCategories'] as List<dynamic>?;
        final vendorId = vendorSnapshot.docs.first.id;

        if (vendorCity == null) return;

        // Listen for new requests
        // FirebaseFirestore.instance
        //     .collection('serviceRequests')
        //     .where('status', isEqualTo: 'pending')
        //     .where('city', isEqualTo: vendorCity)
        //     .snapshots()
        //     .listen((snapshot) {
        //   for (var change in snapshot.docChanges) {
        //     if (change.type == DocumentChangeType.added) {
        //       final request = change.doc.data();
        //       if (request == null) continue;
        //
        //       final subCategory = request['subCategory'] as String?;
        //       if (subCategory != null && categories?.contains(subCategory) == true) {
        //         _requestHandler.showNotification(
        //           title: 'New Service Request',
        //           body: 'New $subCategory request in your area',
        //           payload: change.doc.id,
        //           context: context,
        //         );
        //       }
        //     }
        //   }
        // });

        // Listen for status changes in assigned requests
        FirebaseFirestore.instance
            .collection('serviceRequests')
            .where('vendorId', isEqualTo: vendorId)
            .snapshots()
            .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final request = change.doc.data();
              if (request == null) continue;

              final status = request['status'] as String?;
              String title = '';
              String body = '';

              switch (status?.toLowerCase()) {
                case 'accepted':
                  title = 'Order Status Updated';
                  body = 'Order has been accepted successfully';
                  break;
                case 'completed':
                  title = 'Order Completed';
                  body = 'Order has been marked as completed';
                  break;
                case 'rejected':
                  title = 'Order Rejected';
                  body = 'Order has been rejected';
                  break;
              }

              if (title.isNotEmpty) {
                _requestHandler.showNotification(
                  title: title,
                  body: body,
                  payload: change.doc.id,
                  context: context,
                );
              }
            }
          }
        });
      }
    }).catchError((error) {
      print('Error fetching vendor details: $error');
    });
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

        // Track processed request IDs to avoid duplicate notifications
        Set<String> processedRequestIds = {};

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
            
            // Show notification only for new requests that haven't been processed
            for (var doc in requests) {
              if (!processedRequestIds.contains(doc.id)) {
                processedRequestIds.add(doc.id);
                final request = doc.data();
                final subCategory = request['subCategory'] as String?;

                if (subCategory != null) {
                  _requestHandler.showNotification(
                    title: 'New Service Request',
                    body: 'New $subCategory request in your area',
                    payload: doc.id,
                    context: context,
                  );
                }
              }
            }

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
          .collection('serviceRequests')
          .where('vendorId', isEqualTo: user.uid)
          .where('status', whereIn: ['accepted', 'completed'])
          .orderBy('lastUpdated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
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
            final isAccepted = order['status'] == 'accepted';
            final isCompleted = order['status'] == 'completed';

            return ServiceRequestCard(
              request: order,
              requestId: orders[index].id,
              showActions: false,
              vendorId: user.uid,
              onComplete: isAccepted ? () async {
                await _requestHandler.completeServiceRequest(
                  requestId: orders[index].id,
                  vendorId: user.uid,
                  context: context,
                  priceRange: order['priceRange'] ?? 0.0,
                );
                setState(() {});
              } : null,
              showCompleteButton: isAccepted,
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
  final Function()? onComplete;
  final bool showCompleteButton;
  final VendorRequestHandler _requestHandler = VendorRequestHandler();

  ServiceRequestCard({
    Key? key,
    required this.request,
    required this.requestId,
    this.showActions = true,
    this.vendorId,
    this.onComplete,
    this.showCompleteButton = false,
  }) : super(key: key);

  void _acceptRequest(BuildContext context, String vendorId) {
    _requestHandler.acceptServiceRequest(
      requestId: requestId,
      vendorId: vendorId,
      vendorName: request['vendorName'] ?? '',
      context: context,
    );

    // Switch to the "My Orders" tab after accepting the request
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      tabController.animateTo(1); // Assuming "My Orders" is the second tab
    }
  }

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
              backgroundColor: Color(0xFF2B5F56),
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
                      ? () => _acceptRequest(context, user.uid)
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
            if (showCompleteButton) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleComplete(context),
                    label: Text('Complete Order'),
                    icon: Icon(Icons.arrow_forward_ios,color: Colors.white,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2B5F56),
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
                        Icon(Icons.check_circle, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.grey,
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
        return Colors.blueGrey;
      case 'accepted':
        return Color(0xFFEDB232);
      case 'assigned':
        return Color(0xFFEDB232);
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
        title: Text(
          'Reject Request',
          style: TextStyle(
            color:  Color(0xFFEDB232), // Set text color
            fontWeight: FontWeight.bold, // Optional: Make it bold
            fontSize: 16, // Optional: Adjust font size
          ),
        ),

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
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2B5F56), // Set the color explicitly
            ),
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