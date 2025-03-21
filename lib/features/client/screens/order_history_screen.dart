import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FlutterLocalNotificationsPlugin.dart';
import 'request_confirmation_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenForOrderUpdates();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestConfirmationScreen(
                requestId: details.payload!,
                vendorName: null,
              ),
            ),
          );
        }
      },
    );
  }

  void _listenForOrderUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('clientEmail', isEqualTo: user.email)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          _handleOrderStatusChange(data);
        }
      }
    });
  }

  void _handleOrderStatusChange(Map<String, dynamic> orderData) {
    String title = '';
    String body = '';

    switch (orderData['status']) {
      case 'accepted':
        title = 'Order Accepted';
        body = 'Your order has been accepted by ${orderData['vendorName']}';
        break;
      case 'rejected':
        title = 'Order Rejected';
        body = 'Your order has been rejected. Reason: ${orderData['rejectionReason'] ?? 'No reason provided'}';
        break;
      case 'completed':
        title = 'Order Completed';
        body = 'Your order has been marked as completed';
        break;
    }

    if (title.isNotEmpty) {
      showNotification(
        title: title,
        body: body,
        context: context,
        payload: orderData['requestId'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Color(0xFF2B5F56),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .where('clientEmail', isEqualTo: user?.email)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error fetching data: ${snapshot.error}');
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5F56)),));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final request = snapshot.data!.docs[index];
              final data = request.data() as Map<String, dynamic>;
              
              String formattedDate = 'N/A';
              if (data['createdAt'] != null) {
                final timestamp = (data['createdAt'] as Timestamp).toDate();
                formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
              }

              final categoryDetails = data['categorySpecificDetails'] as Map<String, dynamic>?;
              final serviceType = categoryDetails?['cleaningServiceType'] ?? '';
              final homeSize = categoryDetails?['homeSize'] ?? '';

              return Card(
                margin: EdgeInsets.only(bottom: 16),
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
                              '${data['mainCategory']} - ${data['subCategory']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusChip(data['status'] ?? 'pending'),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (serviceType.isNotEmpty) Text('Service: $serviceType'),
                      if (homeSize.isNotEmpty) Text('Home Size: $homeSize'),
                      Text('Date: ${data['selectedDate'] ?? 'Not set'}'),
                      Text('Time: ${data['selectedTime'] ?? 'Not set'}'),
                      Text('Created: $formattedDate'),
                      if (data['vendorName'] != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Vendor: ${data['vendorName']}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestConfirmationScreen(
                                  requestId: request.id,
                                  vendorName: data['vendorName'] ?? 'Not assigned',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'View Details',
                            style: TextStyle(color: Color(0xFF2B5F56)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'accepted':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      case 'completed':
        chipColor = Color(0xFF2B5F56);
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Future<void> showNotification({
  required String title,
  required String body,
  required BuildContext context,
  String? payload,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'home_services',
    'Home Services',
    channelDescription: 'Notifications for home services app',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
} 