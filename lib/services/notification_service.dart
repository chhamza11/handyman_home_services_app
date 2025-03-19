// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io' show Platform;
//
// // Import the global instance from main.dart
// import '../main.dart' show flutterLocalNotificationsPlugin;
//
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//
//   Future<void> initialize() async {
//     // Request permission for iOS devices
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }
//
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotificationFromMessage(message);
//     });
//
//     // Handle when app is opened from notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification opened app: ${message.data}');
//     });
//   }
//
//   Future<void> updateFCMToken() async {
//     try {
//       final token = await _firebaseMessaging.getToken();
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (token != null && user != null) {
//         // Update token in both vendors and clients nodes
//         await _database
//             .child('vendors')
//             .child(user.uid)
//             .update({'fcmToken': token});
//
//         await _database
//             .child('clients')
//             .child(user.uid)
//             .update({'fcmToken': token});
//       }
//     } catch (e) {
//       print('Error updating FCM token: $e');
//     }
//   }
//
//   Future<void> sendNotification({
//     required String userId,
//     required String title,
//     required String body,
//     required String requestId,
//     String? userType,
//   }) async {
//     try {
//       // Get the user's FCM token from the database
//       final userSnapshot = await _database
//           .child(userType == 'vendor' ? 'vendors' : 'clients')
//           .child(userId)
//           .get();
//
//       if (!userSnapshot.exists) {
//         throw Exception('User not found');
//       }
//
//       final userData = userSnapshot.value as Map<dynamic, dynamic>?;
//       final fcmToken = userData?['fcmToken'];
//
//       if (fcmToken != null) {
//         await _database.child('notifications').push().set({
//           'userId': userId,
//           'userType': userType,
//           'title': title,
//           'body': body,
//           'requestId': requestId,
//           'timestamp': ServerValue.timestamp,
//           'read': false,
//           'fcmToken': fcmToken,
//         });
//       }
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }
//
//   Future<void> _showNotificationFromMessage(RemoteMessage message) async {
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'service_requests',
//       'Service Requests',
//       channelDescription: 'Notifications for service requests',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//       enableVibration: true,
//       enableLights: true,
//     );
//
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecond,
//       message.notification?.title ?? 'New Notification',
//       message.notification?.body ?? '',
//       platformChannelSpecifics,
//       payload: message.data['requestId'],
//     );
//   }
//
//   Future<bool> requestPermissions() async {
//     final status = await Permission.notification.request();
//     return status.isGranted;
//   }
//
//   Future<void> showNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'service_requests',
//       'Service Requests',
//       channelDescription: 'Notifications for service requests',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//     );
//
//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }
//
//   Future<void> checkAndRequestPermissions(BuildContext context) async {
//     final status = await Permission.notification.status;
//
//     if (status.isDenied) {
//       final shouldRequest = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Notifications Permission'),
//           content: Text(
//             'We need notification permissions to keep you updated about your service requests. '
//             'Would you like to enable notifications?'
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text('No, thanks'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: Text('Enable'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF2B5F56),
//               ),
//             ),
//           ],
//         ),
//       );
//
//       if (shouldRequest == true) {
//         await requestPermissions();
//       }
//     } else if (status.isPermanentlyDenied) {
//       await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Notifications Disabled'),
//           content: Text(
//             'Notifications are disabled permanently. Please enable them in your device settings to receive updates about your service requests.'
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 openAppSettings();
//                 Navigator.pop(context);
//               },
//               child: Text('Open Settings'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF2B5F56),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
//   // Initialize notifications for background messages if needed
//   await NotificationService()._showNotificationFromMessage(message);
// }