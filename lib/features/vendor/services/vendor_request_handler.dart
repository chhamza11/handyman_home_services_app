import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class VendorRequestHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Check and request notifications permission
  Future<bool> _requestNotificationPermissions() async {
    try {
      final status = await Permission.notification.status;
      
      if (status.isDenied) {
        // Request permission
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        return false;
      }
      
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Show settings dialog if permission is permanently denied
  void showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Notifications Permission'),
        content: Text(
          'Notifications permission is required to receive order updates. '
          'Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Initialize notifications with permission check
  Future<void> initNotifications(BuildContext context) async {
    try {
      // Check/request permission first
      final hasPermission = await _requestNotificationPermissions();
      
      if (!hasPermission) {
        showPermissionSettingsDialog(context);
        return;
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );

      // Additional Android-specific permissions
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Show local notification with permission check
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    required BuildContext context,
  }) async {
    try {
      final hasPermission = await Permission.notification.status;
      
      if (!hasPermission.isGranted) {
        showPermissionSettingsDialog(context);
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'home_services',
        'Home Services',
        channelDescription: 'Notifications for home services app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        fullScreenIntent: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableRequests({
    required String vendorId,
    required String city,
    required List<String> serviceCategories,
    required List<String> subCategories,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('serviceRequests')
          .where('status', isEqualTo: 'pending')
          .where('city', isEqualTo: city);

      if (serviceCategories.isNotEmpty) {
        query = query.where('mainCategory', whereIn: serviceCategories);
      }

      return query
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting available requests: $e');
      rethrow;
    }
  }

  Future<void> acceptServiceRequest({
    required String requestId,
    required String vendorId,
    required String vendorName,
    required BuildContext context,
  }) async {
    try {
      final requestDoc = await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;
      
      await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .update({
            'status': 'accepted',
            'vendorId': vendorId,
            'vendorName': vendorName,
            'acceptedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Add notification to client's collection
      await _firestore.collection('notifications').add({
        'userId': requestData['clientId'],
        'title': 'Order Accepted',
        'body': 'Your service request has been accepted by $vendorName',
        'type': 'order_accepted',
        'orderId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error accepting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> rejectServiceRequest({
    required String requestId,
    required String vendorId,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('serviceRequests').doc(requestId);
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          throw Exception('Request not found');
        }

        transaction.update(requestRef, {
          'status': 'rejected',
          'rejectedBy': vendorId,
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request rejected'),
          backgroundColor: Colors.orange,
        ),
      );

    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get vendor details
  Future<Map<String, dynamic>?> getVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> vendorDoc =
      await _firestore.collection('vendors').doc(vendorId).get();

      return vendorDoc.data();
    } catch (e) {
      print('Error getting vendor details: $e');
      return null;
    }
  }

  // Helper method to check if request is still available
  Future<bool> isRequestAvailable(String requestId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestDoc =
      await _firestore.collection('serviceRequests').doc(requestId).get();

      return requestDoc.exists &&
          requestDoc.data()?['status'] == 'pending';
    } catch (e) {
      print('Error checking request availability: $e');
      return false;
    }
  }

  Future<void> completeServiceRequest({
    required String requestId,
    required String vendorId,
    required BuildContext context,
    required double priceRange,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('serviceRequests').doc(requestId);
        final vendorStatsRef = _firestore.collection('vendorStats').doc(vendorId);
        
        // Get current documents
        final requestDoc = await transaction.get(requestRef);
        final vendorStatsDoc = await transaction.get(vendorStatsRef);
        
        if (!requestDoc.exists) {
          throw Exception('Request not found');
        }

        // Update request status
        transaction.update(requestRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'finalAmount': priceRange,
        });

        // Update vendor stats
        if (!vendorStatsDoc.exists) {
          transaction.set(vendorStatsRef, {
            'totalEarnings': priceRange,
            'totalOrders': 1,
            'completedOrders': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          final currentStats = vendorStatsDoc.data() as Map<String, dynamic>;
          transaction.update(vendorStatsRef, {
            'totalEarnings': (currentStats['totalEarnings'] ?? 0.0) + priceRange,
            'completedOrders': (currentStats['completedOrders'] ?? 0) + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error completing request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 